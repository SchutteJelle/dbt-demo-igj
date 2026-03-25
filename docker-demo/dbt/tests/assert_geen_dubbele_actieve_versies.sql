-- =============================================================================
-- Singular test: assert_geen_dubbele_actieve_versies
--
-- Doel:
--   Verifieer dat elk bron_systeem_id maximaal één actieve versie heeft
--   in het SCD2 intermediate model. Als er twee actieve versies zijn voor
--   hetzelfde record, is de SCD2 logica fout gegaan.
--
-- Deze test beschermt de integriteit van de SCD2 implementatie.
-- =============================================================================

SELECT
    bron_systeem_id,
    COUNT(*) AS aantal_actieve_versies

FROM {{ ref('int_plaatsingen_scd2') }}

WHERE is_actief_versie = 1

GROUP BY bron_systeem_id

-- Een record met meer dan één actieve versie = SCD2 logicafout
HAVING COUNT(*) > 1
