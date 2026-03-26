-- =============================================================================
-- Model: stg_beschermende_plaatsingen
-- Laag:  Staging  |  Materialisatie: View
--
-- PostgreSQL versie van het staging model.
-- SQL Server → PostgreSQL aanpassingen:
--   RIGHT('00000000' + ..., 8)  →  LPAD(..., 8, '0')
--   GETDATE()                   →  NOW()
-- Alle overige SQL is standaard en werkt op beide platformen.
-- =============================================================================

{{ config(materialized='view') }}

WITH brondata AS (

    SELECT
        id,
        bsn_geanonimiseerd,
        zorgaanbieder_agb_code,
        machtigingsvorm,
        startdatum_plaatsing,
        einddatum_plaatsing,
        locatie_code,
        diagnose_code,
        kwartaal_levering,
        aanleverdatum,
        bron_systeem_id,
        record_status,
        xml_payload
    FROM {{ ref('raw_xml_beschermende_plaatsingen') }}

),

uitgepakt_xml AS (

    SELECT
        COALESCE(
            NULLIF((xpath('/plaatsing/id/text()', xmlparse(document xml_payload)))[1]::text, ''),
            id::text
        ) AS id,

        COALESCE(
            NULLIF((xpath('/plaatsing/bsn_geanonimiseerd/text()', xmlparse(document xml_payload)))[1]::text, ''),
            bsn_geanonimiseerd
        ) AS bsn_geanonimiseerd,

        COALESCE(
            NULLIF((xpath('/plaatsing/zorgaanbieder_agb_code/text()', xmlparse(document xml_payload)))[1]::text, ''),
            zorgaanbieder_agb_code
        ) AS zorgaanbieder_agb_code,

        COALESCE(
            NULLIF((xpath('/plaatsing/machtigingsvorm/text()', xmlparse(document xml_payload)))[1]::text, ''),
            machtigingsvorm
        ) AS machtigingsvorm,

        COALESCE(
            NULLIF((xpath('/plaatsing/startdatum_plaatsing/text()', xmlparse(document xml_payload)))[1]::text, ''),
            startdatum_plaatsing::text
        ) AS startdatum_plaatsing,

        COALESCE(
            NULLIF((xpath('/plaatsing/einddatum_plaatsing/text()', xmlparse(document xml_payload)))[1]::text, ''),
            einddatum_plaatsing::text
        ) AS einddatum_plaatsing,

        COALESCE(
            NULLIF((xpath('/plaatsing/locatie_code/text()', xmlparse(document xml_payload)))[1]::text, ''),
            locatie_code
        ) AS locatie_code,

        COALESCE(
            NULLIF((xpath('/plaatsing/diagnose_code/text()', xmlparse(document xml_payload)))[1]::text, ''),
            diagnose_code
        ) AS diagnose_code,

        COALESCE(
            NULLIF((xpath('/plaatsing/kwartaal_levering/text()', xmlparse(document xml_payload)))[1]::text, ''),
            kwartaal_levering
        ) AS kwartaal_levering,

        COALESCE(
            NULLIF((xpath('/plaatsing/aanleverdatum/text()', xmlparse(document xml_payload)))[1]::text, ''),
            aanleverdatum::text
        ) AS aanleverdatum,

        COALESCE(
            NULLIF((xpath('/plaatsing/bron_systeem_id/text()', xmlparse(document xml_payload)))[1]::text, ''),
            bron_systeem_id
        ) AS bron_systeem_id,

        COALESCE(
            NULLIF((xpath('/plaatsing/record_status/text()', xmlparse(document xml_payload)))[1]::text, ''),
            record_status
        ) AS record_status

    FROM brondata

),

opgeschoond AS (

    SELECT
        -- Surrogate key op basis van bron_systeem_id + kwartaal_levering
        {{ dbt_utils.generate_surrogate_key([
            'bron_systeem_id',
            'kwartaal_levering'
        ]) }} AS plaatsing_sk,

        -- Bronsleutels
        CAST(id AS INTEGER)                              AS bron_id,
        TRIM(bsn_geanonimiseerd)                         AS bsn_geanonimiseerd,

        -- AGB-code: opvullen met voorloopnullen naar 8 tekens
        -- PostgreSQL: LPAD() (SQL Server gebruikte RIGHT('00000000' + ..., 8))
        LPAD(TRIM(zorgaanbieder_agb_code), 8, '0')       AS zorgaanbieder_agb_code,

        TRIM(bron_systeem_id)                            AS bron_systeem_id,

        -- Machtigingsvorm normaliseren naar hoofdletters
        UPPER(TRIM(machtigingsvorm))                     AS machtigingsvorm,

        -- Datums: casten naar DATE (strips tijdcomponent)
        CAST(startdatum_plaatsing AS DATE)               AS startdatum_plaatsing,
        CAST(einddatum_plaatsing AS DATE)                AS einddatum_plaatsing,

        -- Locatie en diagnose
        TRIM(UPPER(locatie_code))                        AS locatie_code,
        REPLACE(TRIM(UPPER(diagnose_code)), '.', '')     AS diagnose_code,
        TRIM(UPPER(diagnose_code))                       AS diagnose_code_origineel,

        -- Kwartaalinformatie
        TRIM(kwartaal_levering)                          AS kwartaal_levering,
        CAST(LEFT(TRIM(kwartaal_levering), 4) AS INTEGER) AS levering_jaar,
        CAST(RIGHT(TRIM(kwartaal_levering), 1) AS INTEGER) AS levering_kwartaal_nummer,

        -- Record metadata
        CAST(aanleverdatum AS DATE)                      AS aanleverdatum,
        LOWER(TRIM(record_status))                       AS record_status,

        -- Technische metadata
        -- PostgreSQL: NOW() (SQL Server gebruikte GETDATE())
        NOW()                                            AS _geladen_op

    FROM uitgepakt_xml

)

SELECT * FROM opgeschoond
