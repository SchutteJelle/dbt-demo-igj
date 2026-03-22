-- =============================================================================
-- Model: mart_beschermende_plaatsingen
-- Laag:  Marts
-- Materialisatie: Incremental
--
-- Doel:
--   De finale presentatielaag voor dashboards en analyses. Dit model bevat
--   alleen de MEEST RECENTE versie van elke plaatsing (is_actief_versie = 1),
--   verrijkt met berekende kolommen voor rapportage.
--
-- Wat is een INCREMENTAL model?
--   Bij een incrementeel model verwerkt DBT alleen NIEUWE of GEWIJZIGDE records,
--   in plaats van de hele tabel te herbouwen. Dit is veel sneller bij grote datasets.
--
--   Werking:
--   1. Eerste run (--full-refresh): bouw de volledige tabel
--   2. Volgende runs: voeg alleen records toe die nieuwer zijn dan de laatste run
--
--   De sleutel is de unique_key: als een record al bestaat (zelfde sleutel),
--   dan wordt het bijgewerkt (MERGE/UPSERT). Anders wordt het ingevoegd.
--
-- Leer-tip: Incrementele modellen zijn essentieel voor productiesystemen met
-- grote hoeveelheden data. Het configuratie-blok onderaan bepaalt de strategie.
-- =============================================================================

{{
    config(
        materialized='incremental',

        -- unique_key: de kolom(men) die een record uniek identificeren.
        -- Bij een nieuwe run: als bron_systeem_id al bestaat -> UPDATE
        --                     als bron_systeem_id nieuw is   -> INSERT
        unique_key='bron_systeem_id',

        -- incremental_strategy: hoe worden updates verwerkt?
        -- 'merge' = gebruik SQL MERGE statement (aanbevolen voor SQL Server)
        incremental_strategy='merge',

        -- on_schema_change: wat te doen als het model nieuwe kolommen krijgt?
        -- 'append_new_columns' = voeg nieuwe kolommen toe, verwijder geen bestaande
        on_schema_change='append_new_columns'
    )
}}

-- =============================================================================
-- Referentiedata: haal actieve plaatsingen op uit de SCD2 intermediate laag
-- =============================================================================
WITH actieve_plaatsingen AS (

    SELECT *
    FROM {{ ref('int_plaatsingen_scd2') }}

    -- Alleen de meest actuele versie van elk record meenemen in de mart
    -- Historische versies zijn beschikbaar in int_plaatsingen_scd2 zelf
    WHERE is_actief_versie = 1
      AND is_ingetrokken = 0        -- Ingetrokken plaatsingen niet tonen

),

-- =============================================================================
-- STAP 1: Bereken de afgeleide kolommen voor het dashboard
-- =============================================================================
berekende_kolommen AS (

    SELECT
        -- -----------------------------------------------------------------------
        -- Sleutels
        -- -----------------------------------------------------------------------
        plaatsing_versie_sk,
        plaatsing_sk,
        bron_systeem_id,
        bron_id,

        -- -----------------------------------------------------------------------
        -- Dimensies (groeperingskolommen voor het dashboard)
        -- -----------------------------------------------------------------------
        bsn_geanonimiseerd,
        zorgaanbieder_agb_code,
        machtigingsvorm,
        locatie_code,
        diagnose_code,
        diagnose_code_origineel,

        -- Eerste twee tekens van ICD-10 = diagnostische hoofdgroep
        -- Bijv. 'F20' (schizofrenie) -> 'F2' (schizofrenie-groep)
        LEFT(diagnose_code, 2)               AS diagnose_hoofdgroep,

        -- -----------------------------------------------------------------------
        -- Datums
        -- -----------------------------------------------------------------------
        startdatum_plaatsing,
        einddatum_plaatsing,
        aanleverdatum,
        kwartaal_levering,
        levering_jaar,
        levering_kwartaal_nummer,
        valid_from,
        valid_to,

        -- -----------------------------------------------------------------------
        -- Berekende kolommen: DUUR
        -- DATEDIFF() berekent het verschil in dagen tussen twee datums
        -- Als einddatum NULL is (plaatsing nog actief), gebruik dan vandaag
        -- -----------------------------------------------------------------------
        DATEDIFF(
            DAY,
            startdatum_plaatsing,
            COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
        ) AS duur_plaatsing_dagen,

        -- Duur in weken (afgerond naar beneden)
        DATEDIFF(
            DAY,
            startdatum_plaatsing,
            COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
        ) / 7 AS duur_plaatsing_weken,

        -- -----------------------------------------------------------------------
        -- Berekende kolommen: STATUS INDICATOREN
        -- -----------------------------------------------------------------------

        -- Is de plaatsing momenteel actief? (geen einddatum of einddatum in toekomst)
        CASE
            WHEN einddatum_plaatsing IS NULL THEN 1
            WHEN einddatum_plaatsing >= CAST(GETDATE() AS DATE) THEN 1
            ELSE 0
        END AS is_actief_record,

        -- Is dit een langdurige plaatsing? (meer dan 1 jaar = 365 dagen)
        CASE
            WHEN DATEDIFF(
                DAY,
                startdatum_plaatsing,
                COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
            ) > 365 THEN 1
            ELSE 0
        END AS is_langdurige_plaatsing,

        -- Plaatsingscategorie op basis van duur (voor dashboard segmentatie)
        CASE
            WHEN DATEDIFF(
                DAY,
                startdatum_plaatsing,
                COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
            ) <= 3   THEN '1. Kort (0-3 dagen)'      -- IBS duur
            WHEN DATEDIFF(
                DAY,
                startdatum_plaatsing,
                COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
            ) <= 30  THEN '2. Kort-middel (4-30 dagen)'
            WHEN DATEDIFF(
                DAY,
                startdatum_plaatsing,
                COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
            ) <= 180 THEN '3. Middel (1-6 maanden)'
            WHEN DATEDIFF(
                DAY,
                startdatum_plaatsing,
                COALESCE(einddatum_plaatsing, CAST(GETDATE() AS DATE))
            ) <= 365 THEN '4. Lang (6-12 maanden)'
            ELSE          '5. Zeer lang (> 1 jaar)'
        END AS duur_categorie,

        -- -----------------------------------------------------------------------
        -- Berekende kolommen: KWARTAAL DIMENSIES voor tijdreeks-analyses
        -- -----------------------------------------------------------------------

        -- Kwartaalnummer als leesbare tekst (voor as-labels in dashboard)
        CONCAT(
            CAST(levering_jaar AS VARCHAR(4)),
            '-Q',
            CAST(levering_kwartaal_nummer AS VARCHAR(1))
        ) AS kwartaal_label,

        -- Eerste dag van het rapportagekwartaal (voor datumfilters in dashboard)
        DATEFROMPARTS(
            levering_jaar,
            ((levering_kwartaal_nummer - 1) * 3) + 1,
            1
        ) AS kwartaal_startdatum,

        -- Jaar en kwartaal als sorteerbaar integer (bijv. 20243 = 2024 Q3)
        -- Handig voor sortering in dashboards zonder datumconversie
        (levering_jaar * 10) + levering_kwartaal_nummer AS kwartaal_sorteersleutel,

        -- -----------------------------------------------------------------------
        -- Kwaliteitsindicatoren
        -- -----------------------------------------------------------------------

        -- Zijn er correcties geweest op dit record?
        is_correctie,
        versie_nummer AS aantal_correcties,

        -- Kwaliteitsvlag: heeft dit record mogelijk datumfouten?
        CASE
            WHEN einddatum_plaatsing IS NOT NULL
             AND einddatum_plaatsing < startdatum_plaatsing THEN 1
            ELSE 0
        END AS heeft_datumfout,

        -- -----------------------------------------------------------------------
        -- Technische metadata
        -- -----------------------------------------------------------------------
        record_status,
        versie_nummer,
        totaal_versies,
        _geladen_op,
        GETDATE() AS _mart_bijgewerkt_op

    FROM actieve_plaatsingen

)

-- =============================================================================
-- Finale SELECT voor de mart
-- =============================================================================
SELECT *
FROM berekende_kolommen

-- =============================================================================
-- INCREMENTAL FILTER: Dit blok wordt alleen uitgevoerd bij incrementele runs.
-- is_incremental() is een DBT macro die TRUE geeft als:
--   1. De tabel al bestaat (niet de eerste run)
--   2. Je NIET uitvoert met --full-refresh
--
-- Leer-tip: Het WHERE-blok filtert de BRON, niet de bestemming.
-- DBT voert daarna een MERGE uit op basis van unique_key.
-- =============================================================================
{% if is_incremental() %}

    -- Haal alleen records op die nieuwer zijn dan het nieuwste record in de mart
    -- Dit voorkomt dat we de hele history opnieuw verwerken bij elke run
    WHERE aanleverdatum > (
        SELECT MAX(aanleverdatum)
        FROM {{ this }}  -- {{ this }} verwijst naar de bestaande mart-tabel
    )

{% endif %}
