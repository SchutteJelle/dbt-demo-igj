-- =============================================================================
-- Model: fct_beschermde_plaatsingen
-- Laag:  Marts  |  Materialisatie: Table
--
-- Facts model voor demo-doeleinden: alle versies uit de SCD2 laag inclusief
-- kernmaatstaven zoals duur in dagen en actieve status.
-- =============================================================================

{{ config(materialized='table') }}

WITH bron AS (

    SELECT
        plaatsing_versie_sk,
        plaatsing_sk,
        bron_systeem_id,
        bron_id,
        bsn_geanonimiseerd,
        zorgaanbieder_agb_code,
        machtigingsvorm,
        locatie_code,
        diagnose_code,
        diagnose_code_origineel,
        startdatum_plaatsing,
        einddatum_plaatsing,
        aanleverdatum,
        kwartaal_levering,
        levering_jaar,
        levering_kwartaal_nummer,
        valid_from,
        valid_to,
        is_actief_versie,
        is_ingetrokken,
        is_correctie,
        is_eerste_versie,
        versie_nummer,
        totaal_versies,
        record_status,
        _geladen_op
    FROM {{ ref('int_plaatsingen_scd2') }}

),

facts AS (

    SELECT
        plaatsing_versie_sk,
        plaatsing_sk,
        bron_systeem_id,
        bron_id,
        bsn_geanonimiseerd,
        zorgaanbieder_agb_code,
        machtigingsvorm,
        locatie_code,
        diagnose_code,
        diagnose_code_origineel,
        startdatum_plaatsing,
        einddatum_plaatsing,
        aanleverdatum,
        kwartaal_levering,
        levering_jaar,
        levering_kwartaal_nummer,
        valid_from,
        valid_to,
        is_actief_versie,
        is_ingetrokken,
        is_correctie,
        is_eerste_versie,
        versie_nummer,
        totaal_versies,
        record_status,

        (COALESCE(einddatum_plaatsing, CURRENT_DATE) - startdatum_plaatsing)
            AS duur_plaatsing_dagen,

        CASE
            WHEN einddatum_plaatsing IS NULL THEN 1
            WHEN einddatum_plaatsing >= CURRENT_DATE THEN 1
            ELSE 0
        END AS is_actief_record,

        _geladen_op,
        NOW() AS _fact_bijgewerkt_op

    FROM bron

)

SELECT *
FROM facts