-- =============================================================================
-- Model: int_plaatsingen_scd2
-- Laag:  Intermediate  |  Materialisatie: Table
--
-- Implementeert Slowly Changing Dimension Type 2 (SCD2) logica.
--
-- PostgreSQL aanpassingen t.o.v. SQL Server:
--   DATEFROMPARTS(year, month, day)  →  MAKE_DATE(year, month, day)
-- Window functions (ROW_NUMBER, LEAD) zijn identiek in beide databases.
-- =============================================================================

{{ config(materialized='table') }}

WITH staging AS (

    SELECT *
    FROM {{ ref('stg_beschermende_plaatsingen') }}

),

-- Stap 1: Rangschik alle versies van elk record op aanleverdatum
gerangschikte_versies AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY bron_systeem_id
            ORDER BY
                aanleverdatum ASC,
                levering_jaar ASC,
                levering_kwartaal_nummer ASC
        ) AS versie_nummer,

        COUNT(*) OVER (
            PARTITION BY bron_systeem_id
        ) AS totaal_versies

    FROM staging

),

-- Stap 2: Bepaal valid_from / valid_to per versie
scd2_datums AS (

    SELECT
        gv.*,

        -- valid_from: eerste dag van het kwartaal van aanlevering
        -- PostgreSQL: MAKE_DATE() (SQL Server gebruikte DATEFROMPARTS())
        MAKE_DATE(
            levering_jaar,
            ((levering_kwartaal_nummer - 1) * 3) + 1,
            1
        ) AS valid_from,

        -- valid_to: de valid_from van de volgende versie (NULL = meest recent)
        LEAD(
            MAKE_DATE(
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

-- Stap 3: Voeg SCD2 indicatoren toe
scd2_volledig AS (

    SELECT
        plaatsing_sk,

        {{ dbt_utils.generate_surrogate_key([
            'bron_systeem_id',
            'versie_nummer'
        ]) }} AS plaatsing_versie_sk,

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

        CASE
            WHEN valid_to IS NULL
             AND LOWER(record_status) != 'intrekking'
            THEN 1
            ELSE 0
        END AS is_actief_versie,

        CASE
            WHEN LOWER(record_status) = 'intrekking' THEN 1
            ELSE 0
        END AS is_ingetrokken,

        CASE
            WHEN LOWER(record_status) = 'correctie' THEN 1
            ELSE 0
        END AS is_correctie,

        CASE WHEN versie_nummer = 1 THEN 1 ELSE 0 END AS is_eerste_versie,

        _geladen_op

    FROM scd2_datums

)

SELECT
    plaatsing_versie_sk,
    plaatsing_sk,
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

ORDER BY bron_systeem_id, versie_nummer
