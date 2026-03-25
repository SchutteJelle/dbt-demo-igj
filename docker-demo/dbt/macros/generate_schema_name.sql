-- =============================================================================
-- generate_schema_name macro
-- Overschrijft het standaard DBT schema-naamgevingsgedrag.
--
-- Standaard gedrag: '{target_schema}_{custom_schema}' (bijv. 'public_raw')
-- Dit macro gedrag:  '{custom_schema}' als opgegeven, anders '{target_schema}'
--
-- Voordeel: schemas in de database matchen precies wat je configureert:
--   seeds met +schema: raw  → schema 'raw'  (niet 'public_raw')
--   models met +schema: staging → schema 'staging' (niet 'public_staging')
--
-- Leer-tip: Macros in de macros/ map overschrijven ingebouwde macros met
-- dezelfde naam. Dit is de aanbevolen manier om DBT-gedrag aan te passen.
-- =============================================================================

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
