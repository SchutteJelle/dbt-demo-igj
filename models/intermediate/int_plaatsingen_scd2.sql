-- =============================================================================
-- Model: int_plaatsingen_scd2
-- Laag:  Intermediate
-- Materialisatie: Table
--
-- Doel:
--   Implementeert Slowly Changing Dimension Type 2 (SCD2) logica voor
--   beschermende plaatsingen. Dit is nodig omdat zorgaanbieders gegevens
--   uit eerdere kwartalen kunnen corrigeren in latere kwartalen.
--
-- Wat is SCD Type 2?
--   Bij SCD2 bewaar je ALLE versies van een record. Elke versie heeft:
--   - valid_from: datum waarop deze versie geldig werd
--   - valid_to:   datum waarop deze versie vervangen werd (NULL = huidige versie)
--   - is_actief:  1 voor de meest recente versie, 0 voor historische versies
--
-- Voorbeeld:
--   Kwartaal Q1 2024: plaatsing P001 aangeleverd met startdatum 2024-01-15
--   Kwartaal Q2 2024: correctie op P001, startdatum gecorrigeerd naar 2024-01-10
--
--   Resultaat in SCD2:
--   | bron_id | startdatum   | versie | valid_from | valid_to   | is_actief |
--   |---------|-------------|--------|------------|------------|-----------|
--   | P001    | 2024-01-15  | 1      | 2024-01-15 | 2024-04-01 | 0         |
--   | P001    | 2024-01-10  | 2      | 2024-04-01 | NULL       | 1         |
--
-- Leer-tip: SCD2 is een klassiek datawarehouse patroon. Het stelt je in staat
-- om historische analyses te doen ('hoe zag de data eruit in Q1?') en tegelijk
-- altijd de meest actuele versie beschikbaar te houden.
--
-- Aanpak in dit model (zonder DBT snapshots):
--   We implementeren SCD2 handmatig met window functions, wat meer controle
--   geeft over de correctielogica specifiek voor kwartaalaanleveringen.
-- =============================================================================

{{ config(materialized='table') }}

WITH staging AS (

    -- Haal alle opgeschoonde records op uit de staging laag
    -- {{ ref() }} maakt een referentie naar een ander DBT model
    -- en zorgt dat DBT de juiste volgorde van uitvoering bepaalt (lineage)
    SELECT *
    FROM {{ ref('stg_beschermende_plaatsingen') }}

),

-- =============================================================================
-- STAP 1: Rangschik alle versies van elk record
-- Een 'record' wordt geidentificeerd door bron_systeem_id (unieke id bij
-- de zorgaanbieder). Elk kwartaal kan een nieuwe versie aanleveren.
-- =============================================================================
gerangschikte_versies AS (

    SELECT
        *,
        -- ROW_NUMBER() geeft elke levering van hetzelfde bron_systeem_id
        -- een oplopend versienummer, gesorteerd op aanleverdatum.
        -- Leer-tip: ROW_NUMBER() is een window function - het berekent
        -- een waarde PER RIJ, gebaseerd op een groep (PARTITION BY) en volgorde (ORDER BY).
        ROW_NUMBER() OVER (
            PARTITION BY bron_systeem_id          -- Groepeer per plaatsing
            ORDER BY
                aanleverdatum ASC,                -- Oudste aanlevering = versie 1
                levering_jaar ASC,
                levering_kwartaal_nummer ASC
        ) AS versie_nummer,

        -- Totaal aantal versies van dit record (voor is_actief bepaling)
        COUNT(*) OVER (
            PARTITION BY bron_systeem_id
        ) AS totaal_versies

    FROM staging
    -- Intrekkingen nemen we mee maar markeren ze later als ingetrokken
    -- We filteren hier NIET op record_status zodat we de volledige history bewaren

),

-- =============================================================================
-- STAP 2: Bepaal de geldigheidsdatum voor elke versie
-- valid_from = aanleverdatum van deze versie
-- valid_to   = aanleverdatum van de VOLGENDE versie (of NULL als laatste versie)
-- =============================================================================
scd2_datums AS (

    SELECT
        gv.*,

        -- valid_from: de datum waarop deze versie van het record geldig werd
        -- Dit is de eerste dag van het kwartaal van aanlevering
        -- SQL Server: DATEFROMPARTS(jaar, maand, dag)
        DATEFROMPARTS(
            levering_jaar,
            -- Kwartaal naar eerste maand: Q1=1, Q2=4, Q3=7, Q4=10
            ((levering_kwartaal_nummer - 1) * 3) + 1,
            1
        ) AS valid_from,

        -- valid_to: de valid_from van de VOLGENDE versie (LEAD window function)
        -- Als er geen volgende versie is, geeft LEAD NULL terug = nog steeds actief
        LEAD(
            DATEFROMPARTS(
                levering_jaar,
                ((levering_kwartaal_nummer - 1) * 3) + 1,
                1
            )
        ) OVER (
            PARTITION BY bron_systeem_id
            ORDER BY aanleverdatum ASC, levering_jaar ASC, levering_kwartaal_nummer ASC
        ) AS valid_to

    FROM gerangschikte_versies gv

),

-- =============================================================================
-- STAP 3: Voeg de SCD2 indicatoren toe
-- =============================================================================
scd2_volledig AS (

    SELECT
        -- Surrogate key van het staging model (uniek per rij in brondata)
        plaatsing_sk,

        -- Nieuwe SCD2 surrogate key: uniek per VERSIE van een plaatsing
        -- We combineren de bestaande SK met het versienummer
        {{ dbt_utils.generate_surrogate_key([
            'bron_systeem_id',
            'versie_nummer'
        ]) }} AS plaatsing_versie_sk,

        -- Bronsleutels
        bron_id,
        bron_systeem_id,
        bsn_geanonimiseerd,
        zorgaanbieder_agb_code,

        -- Plaatsingsgegevens (de inhoud die kan veranderen per versie)
        machtigingsvorm,
        startdatum_plaatsing,
        einddatum_plaatsing,
        locatie_code,
        diagnose_code,
        diagnose_code_origineel,

        -- Kwartaalinformatie van DEZE aanlevering
        kwartaal_levering,
        levering_jaar,
        levering_kwartaal_nummer,
        aanleverdatum,
        record_status,

        -- -----------------------------------------------------------------------
        -- SCD2 kolommen
        -- -----------------------------------------------------------------------
        versie_nummer,
        totaal_versies,
        valid_from,
        valid_to,

        -- is_actief_versie: is dit de meest recente versie van dit record?
        -- Een record is actief als:
        --   1. valid_to IS NULL (er is geen nieuwere versie), EN
        --   2. De record_status is NIET 'intrekking'
        CASE
            WHEN valid_to IS NULL
             AND LOWER(record_status) != 'intrekking'
            THEN 1
            ELSE 0
        END AS is_actief_versie,

        -- is_ingetrokken: werd dit record expliciet ingetrokken door de aanbieder?
        CASE
            WHEN LOWER(record_status) = 'intrekking' THEN 1
            ELSE 0
        END AS is_ingetrokken,

        -- is_correctie: is dit record een correctie op een eerder aangeleverd record?
        CASE
            WHEN LOWER(record_status) = 'correctie' THEN 1
            ELSE 0
        END AS is_correctie,

        -- is_eerste_versie: is dit de originele aanlevering?
        CASE WHEN versie_nummer = 1 THEN 1 ELSE 0 END AS is_eerste_versie,

        -- Technische metadata
        _geladen_op

    FROM scd2_datums

)

-- =============================================================================
-- Finale output: alle versies van alle plaatsingen met SCD2 metadata
-- =============================================================================
SELECT
    plaatsing_versie_sk,    -- Primaire sleutel van dit model (uniek per versie)
    plaatsing_sk,           -- Sleutel terug naar staging (voor traceerbaarheid)
    bron_id,
    bron_systeem_id,
    bsn_geanonimiseerd,
    zorgaanbieder_agb_code,
    machtigingsvorm,
    startdatum_plaatsing,
    einddatum_plaatsing,
    locatie_code,
    diagnose_code,
    diagnose_code_origineel,
    kwartaal_levering,
    levering_jaar,
    levering_kwartaal_nummer,
    aanleverdatum,
    record_status,
    versie_nummer,
    totaal_versies,
    valid_from,
    valid_to,
    is_actief_versie,
    is_ingetrokken,
    is_correctie,
    is_eerste_versie,
    _geladen_op

FROM scd2_volledig

-- Optioneel: sorteer op bron_systeem_id en versienummer voor leesbaarheid
-- (heeft geen functioneel effect, wel handig bij handmatige inspectie)
ORDER BY bron_systeem_id, versie_nummer
