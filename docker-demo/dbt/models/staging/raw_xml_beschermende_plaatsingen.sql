-- =============================================================================
-- Model: raw_xml_beschermende_plaatsingen
-- Laag:  Staging  |  Materialisatie: View
--
-- Doel: expliciete tussenlaag om ruwe XML-aanleveringen zichtbaar te maken
-- in lineage. Dit model leest direct uit de raw source en houdt xml_payload
-- intact voor verdere verwerking.
-- =============================================================================

{{ config(materialized='view') }}

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
FROM {{ source('igj_raw', 'beschermende_plaatsingen') }}
