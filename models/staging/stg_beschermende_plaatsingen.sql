-- =============================================================================
-- Model: stg_beschermende_plaatsingen
-- Laag:  Staging
-- Materialisatie: View
--
-- Doel:
--   Dit model leest de ruwe brondata uit de landingstabel en voert de eerste
--   opschoonstap uit. De staging laag heeft precies één doel: de bron zo
--   getrouw mogelijk weergeven, maar dan netjes getypeerd en genormaliseerd.
--
-- Wat dit model doet:
--   1. Selecteert alle relevante kolommen uit de bron
--   2. Cast datatypes expliciet naar de juiste typen
--   3. Normaliseert tekstwaarden (trim, upper/lower)
--   4. Genereert een surrogate key op basis van inhoud
--   5. Filtert geen records weg (dat is werk voor downstream modellen)
--
-- Leer-tip: Een staging model raakt nooit de businesslogica aan. Het is een
-- schone spiegel van de bron. Joins, berekeningen en filters horen thuis
-- in de intermediate of mart laag.
-- =============================================================================

-- Configuratie: als view materialiseren (standaard voor staging)
{{ config(materialized='view') }}

WITH brondata AS (

    -- {{ source() }} vertelt DBT waar de ruwe data vandaan komt.
    -- Dit is gedefinieerd in schema.yml onder 'sources'.
    -- DBT gebruikt dit om lineage (herkomst) bij te houden.
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
        record_status
    FROM {{ source('igj_raw', 'beschermende_plaatsingen') }}

),

opgeschoond AS (

    SELECT
        -- -----------------------------------------------------------------------
        -- Surrogate key: een unieke rij-identifier op basis van inhoud.
        -- dbt_utils.generate_surrogate_key() maakt een MD5-hash van de
        -- opgegeven kolommen. Dit is stabieler dan een database auto-increment id
        -- omdat de hash consistent is ongeacht wanneer je de pipeline draait.
        --
        -- We combineren bron_systeem_id + kwartaal_levering zodat correcties
        -- in een later kwartaal een andere surrogate key krijgen.
        -- -----------------------------------------------------------------------
        {{ dbt_utils.generate_surrogate_key([
            'bron_systeem_id',
            'kwartaal_levering'
        ]) }} AS plaatsing_sk,

        -- -----------------------------------------------------------------------
        -- Bronsleutels en identificatie
        -- -----------------------------------------------------------------------

        -- De originele database auto-increment (bewaren voor traceerbaarheid)
        CAST(id AS INT)                                  AS bron_id,

        -- BSN is al geanonimiseerd (gehasht) door de zorgaanbieder
        -- We bewaren het als VARCHAR - nooit terug proberen te hashen!
        TRIM(bsn_geanonimiseerd)                         AS bsn_geanonimiseerd,

        -- AGB-code is altijd 8 cijfers; LPAD-equivalent in SQL Server: RIGHT('00000000' + ..., 8)
        RIGHT('00000000' + TRIM(zorgaanbieder_agb_code), 8)
                                                         AS zorgaanbieder_agb_code,

        -- Unieke ID in het bronsysteem van de zorgaanbieder
        TRIM(bron_systeem_id)                            AS bron_systeem_id,

        -- -----------------------------------------------------------------------
        -- Machtigingsvorm normaliseren naar hoofdletters
        -- Geldige waarden: 'IBS', 'RM', 'ZM' (zie dbt_project.yml vars)
        -- -----------------------------------------------------------------------
        UPPER(TRIM(machtigingsvorm))                     AS machtigingsvorm,

        -- -----------------------------------------------------------------------
        -- Datums: expliciet casten naar DATE
        -- SQL Server: CAST(... AS DATE) strips de tijdcomponent
        -- -----------------------------------------------------------------------
        CAST(startdatum_plaatsing AS DATE)               AS startdatum_plaatsing,

        -- einddatum kan NULL zijn (plaatsing is nog actief)
        CAST(einddatum_plaatsing AS DATE)                AS einddatum_plaatsing,

        -- -----------------------------------------------------------------------
        -- Locatie en diagnose
        -- -----------------------------------------------------------------------
        TRIM(UPPER(locatie_code))                        AS locatie_code,

        -- ICD-10 code normaliseren: puntje verwijderen voor consistentie
        -- Bijv. 'F20.0' wordt 'F200' voor makkelijker groeperen
        REPLACE(TRIM(UPPER(diagnose_code)), '.', '')     AS diagnose_code,

        -- Originele ICD-10 code bewaren voor rapportage
        TRIM(UPPER(diagnose_code))                       AS diagnose_code_origineel,

        -- -----------------------------------------------------------------------
        -- Kwartaal informatie
        -- Format: 'YYYY-QN' bijv. '2024Q3'
        -- -----------------------------------------------------------------------
        TRIM(kwartaal_levering)                          AS kwartaal_levering,

        -- Jaar extraheren uit kwartaalcode (eerste 4 tekens)
        CAST(LEFT(TRIM(kwartaal_levering), 4) AS INT)    AS levering_jaar,

        -- Kwartaalnummer extraheren (laatste teken)
        CAST(RIGHT(TRIM(kwartaal_levering), 1) AS INT)   AS levering_kwartaal_nummer,

        -- -----------------------------------------------------------------------
        -- Record metadata
        -- -----------------------------------------------------------------------
        CAST(aanleverdatum AS DATE)                      AS aanleverdatum,

        -- Status normaliseren naar lowercase voor consistentie
        -- Geldige waarden: 'nieuw', 'correctie', 'intrekking'
        LOWER(TRIM(record_status))                       AS record_status,

        -- Technische metadata: wanneer is dit record in de landingstabel gezet?
        -- GETDATE() = huidige tijdstip in SQL Server
        GETDATE()                                        AS _geladen_op

    FROM brondata

)

-- Finale SELECT: alles uit de opgeschoonde CTE
SELECT * FROM opgeschoond
