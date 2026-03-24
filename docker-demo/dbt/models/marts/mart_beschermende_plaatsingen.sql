-- =============================================================================
-- Model: mart_beschermende_plaatsingen
-- Laag:  Marts  |  Materialisatie: Incremental
--
-- Finale presentatietabel voor dashboards. Bevat alleen de meest actuele,
-- niet-ingetrokken versie van elke plaatsing.
--
-- PostgreSQL aanpassingen t.o.v. SQL Server:
--   DATEDIFF(DAY, start, end)    →  (end::date - start::date)
--   CAST(GETDATE() AS DATE)      →  CURRENT_DATE
--   DATEFROMPARTS(y, m, d)       →  MAKE_DATE(y, m, d)
--   GETDATE()                    →  NOW()
--   incremental_strategy merge   →  delete+insert (brede PostgreSQL-compatibiliteit)
-- =============================================================================

{{
    config(
        materialized='incremental',
        unique_key='bron_systeem_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns'
    )
}}

WITH actieve_plaatsingen AS (

    SELECT *
    FROM {{ ref('int_plaatsingen_scd2') }}
    WHERE is_actief_versie = 1
      AND is_ingetrokken = 0

),

berekende_kolommen AS (

    SELECT
        -- Sleutels
        plaatsing_versie_sk,
        plaatsing_sk,
        bron_systeem_id,
        bron_id,

        -- Dimensies
        bsn_geanonimiseerd,
        zorgaanbieder_agb_code,
        machtigingsvorm,
        locatie_code,
        diagnose_code,
        diagnose_code_origineel,
        LEFT(diagnose_code, 2)               AS diagnose_hoofdgroep,

        -- Datums
        startdatum_plaatsing,
        einddatum_plaatsing,
        aanleverdatum,
        kwartaal_levering,
        levering_jaar,
        levering_kwartaal_nummer,
        valid_from,
        valid_to,

        -- Duur berekening
        -- PostgreSQL: datumaftrekking geeft integer (dagen)
        -- (SQL Server gebruikte DATEDIFF(DAY, start, end))
        (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing)
                                             AS duur_plaatsing_dagen,

        (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing) / 7
                                             AS duur_plaatsing_weken,

        -- Status indicatoren
        CASE
            WHEN einddatum_plaatsing IS NULL THEN 1
            WHEN einddatum_plaatsing >= CURRENT_DATE THEN 1
            ELSE 0
        END AS is_actief_record,

        CASE
            WHEN (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing) > 365 THEN 1
            ELSE 0
        END AS is_langdurige_plaatsing,

        -- Categorie op basis van duur
        CASE
            WHEN (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing) <= 3
                THEN '1. Kort (0-3 dagen)'
            WHEN (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing) <= 30
                THEN '2. Kort-middel (4-30 dagen)'
            WHEN (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing) <= 180
                THEN '3. Middel (1-6 maanden)'
            WHEN (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing) <= 365
                THEN '4. Lang (6-12 maanden)'
            ELSE '5. Zeer lang (> 1 jaar)'
        END AS duur_categorie,

        -- Kwartaal dimensies
        CONCAT(
            CAST(levering_jaar AS VARCHAR),
            '-Q',
            CAST(levering_kwartaal_nummer AS VARCHAR)
        ) AS kwartaal_label,

        -- PostgreSQL: MAKE_DATE() (SQL Server gebruikte DATEFROMPARTS())
        MAKE_DATE(
            levering_jaar,
            ((levering_kwartaal_nummer - 1) * 3) + 1,
            1
        ) AS kwartaal_startdatum,

        (levering_jaar * 10) + levering_kwartaal_nummer AS kwartaal_sorteersleutel,

        -- Kwaliteitsindicatoren
        is_correctie,
        versie_nummer AS aantal_correcties,

        CASE
            WHEN einddatum_plaatsing IS NOT NULL
             AND einddatum_plaatsing < startdatum_plaatsing THEN 1
            ELSE 0
        END AS heeft_datumfout,

        -- Technische metadata
        record_status,
        versie_nummer,
        totaal_versies,
        _geladen_op,
        NOW() AS _mart_bijgewerkt_op

    FROM actieve_plaatsingen

)

SELECT *
FROM berekende_kolommen

{% if is_incremental() %}

    WHERE aanleverdatum > (
        SELECT MAX(aanleverdatum)
        FROM {{ this }}
    )

{% endif %}
