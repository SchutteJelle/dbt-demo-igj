-- =============================================================================
-- Singular test: assert_einddatum_na_startdatum
-- Test bestand: tests/assert_einddatum_na_startdatum.sql
--
-- Doel:
--   Verifieer dat einddatum_plaatsing altijd NA startdatum_plaatsing valt
--   (of NULL is). Dit is een dataintegriteitsregel die niet als 'accepted_values'
--   of 'not_null' test uitgedrukt kan worden.
--
-- Leer-tip: DBT tests werken op basis van "falen als er rijen teruggegeven worden".
--   - Een Singular test is een los SQL-bestand in de /tests map
--   - Als de query 0 rijen teruggeeft -> test GESLAAGD
--   - Als de query >0 rijen teruggeeft -> test GEFAALD
--
-- Dit is een Singular test (ook wel: data test of bespoke test).
-- Generic tests (not_null, unique, accepted_values) staan in schema.yml.
-- =============================================================================

SELECT
    bron_systeem_id,
    startdatum_plaatsing,
    einddatum_plaatsing,
    kwartaal_levering,
    zorgaanbieder_agb_code

FROM {{ ref('stg_beschermende_plaatsingen') }}

WHERE
    -- Alleen records met een ingevulde einddatum controleren
    einddatum_plaatsing IS NOT NULL

    -- Een einddatum vóór de startdatum is een datafout
    AND einddatum_plaatsing < startdatum_plaatsing
