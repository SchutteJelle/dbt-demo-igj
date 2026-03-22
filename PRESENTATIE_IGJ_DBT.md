---
marp: true
theme: default
paginate: true
title: IGJ Beschermende Plaatsingen - dbt Demo
---

# IGJ Beschermende Plaatsingen
## dbt Demo

Doel van deze presentatie:
- Laten zien hoe we brondata betrouwbaar omzetten naar rapportage-data
- Uitleggen hoe correcties per kwartaal netjes worden verwerkt (SCD2)
- Aantonen welke datakwaliteitscontroles we hebben ingebouwd

---

# Context en Doel

Praktijkscenario:
- Zorgaanbieders leveren kwartaalbestanden met beschermende plaatsingen
- Eerdere kwartalen kunnen later worden gecorrigeerd of ingetrokken
- Toezichthouders willen zowel actuele cijfers als historie kunnen analyseren

Projectdoel:
- Een reproduceerbare, uitlegbare en testbare datalaag bouwen met dbt

---

# Voor Wie Is Dit?

Gebruikersrollen:
- IGJ beleidsanalist: trendanalyse op machtigingsvorm, duur en locatie
- Toezichthouder: signaleren van langdurige of opvallende plaatsingen
- Data engineer: betrouwbare pipeline met duidelijke lineage en tests

Belangrijk resultaat:
- 1 bron van waarheid voor dashboards en rapportages

---

# Architectuur in 3 Lagen

1. Staging
- Opschonen, casten, standaardiseren
- Geen businesslogica

2. Intermediate
- SCD Type 2 logica
- Volledige versiehistorie per plaatsing

3. Mart
- Alleen actuele records voor snelle dashboard-consumptie
- Verrijkte KPI-kolommen

---

# Staging Model

Model: models/staging/stg_beschermende_plaatsingen.sql

Wat gebeurt hier:
- Datatypes expliciet gezet (bijv. datums)
- Tekst gestandaardiseerd (trim, upper/lower)
- Surrogate key aangemaakt met dbt_utils.generate_surrogate_key
- Brondata zo getrouw mogelijk behouden

Waarom belangrijk:
- Consistente invoer voor alle downstream logica

---

# Intermediate Model (SCD2)

Model: models/intermediate/int_plaatsingen_scd2.sql

SCD2-kern:
- Elke wijziging wordt een nieuwe versie
- valid_from: wanneer versie ingaat
- valid_to: wanneer versie eindigt (NULL = huidige)
- is_actief_versie: markeert precies 1 actuele versie

Waarde:
- Historische analyses mogelijk
- Auditeerbaar: je ziet precies wat wanneer gewijzigd is

---

# Mart Model (Incremental)

Model: models/marts/mart_beschermende_plaatsingen.sql

Belangrijkste keuzes:
- Materialisatie: incremental
- Strategy: merge
- unique_key: bron_systeem_id

Toegevoegde rapportagevelden:
- duur_plaatsing_dagen, duur_categorie
- diagnose_hoofdgroep
- kwartaal_label en kwartaal_sorteersleutel
- kwaliteitsvlaggen zoals heeft_datumfout

---

# Datakwaliteit en Tests

Singular tests in tests/:
- assert_einddatum_na_startdatum.sql
- assert_geen_dubbele_actieve_versies.sql

Wat dit afdekt:
- Geen onmogelijke datumlogica
- Geen dubbele actieve versies in SCD2

Praktisch effect:
- Fouten worden vroeg zichtbaar in de pipeline

---

# dbt Configuratie

Bestanden:
- dbt_project.yml
- profiles.yml
- packages.yml

Project-inrichting:
- Per laag eigen schema en standaard materialisatie
- Tags voor gerichte runs (staging/intermediate/marts)
- Variabelen voor startdatum en geldige machtigingsvormen

---

# Demo Flow (Live)

1. Dependencies ophalen
- dbt deps

2. Modellen draaien
- dbt run

3. Tests uitvoeren
- dbt test

4. Documentatie bouwen
- dbt docs generate
- dbt docs serve

Verwachte uitkomst:
- Actuele mart + geslaagde kwaliteitschecks + zichtbare lineage

---

# Wat Levert Dit Op Voor IGJ?

Businesswaarde:
- Snellere en betrouwbaardere kwartaalrapportage
- Inzicht in zowel actuele stand als historische correcties
- Minder handmatige datacontroles

Technische waarde:
- Herhaalbare ETL/ELT met versiebeheer
- Transparante SQL-logica per laag
- Uitbreidbaar naar extra bronnen en KPI's

---

# Volgende Stap

Aanbevolen uitbreiding:
- Extra generic tests (not_null, accepted_values) in schema YAML
- Exposures toevoegen voor BI-dashboard koppelingen
- Data contracts afspreken met aanleverende partijen
- Monitoring op run failures en test regressies

Dank!
Vragen?
