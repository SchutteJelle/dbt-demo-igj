---
marp: true
theme: default
paginate: true
title: IGJ Beschermende Plaatsingen - 10 min
---

# IGJ Beschermende Plaatsingen
## dbt Demo in 10 minuten

Doel:
- In 10 minuten laten zien waarom deze pipeline betrouwbaar is
- Focus op businesswaarde, SCD2-correcties en datakwaliteit

Spreektijd: 45-60 sec

---

# 1. Probleem Dat We Oplossen

Context:
- Zorgaanbieders leveren kwartaaldata met beschermende plaatsingen
- Eerdere kwartalen kunnen later gecorrigeerd worden
- IGJ wil actuele stand en historie kunnen vertrouwen

Kernvraag:
- Hoe maken we rapportage-data consistent, auditeerbaar en herhaalbaar?

Spreektijd: 75 sec

---

# 2. Oplossing: dbt in 3 Lagen

Architectuur:
- Staging: bron opschonen en standaardiseren
- Intermediate: SCD2-versiebeheer voor correcties
- Mart: actuele records + KPI-velden voor dashboards

Waarom dit werkt:
- Duidelijke scheiding van verantwoordelijkheden
- Transparante SQL per stap

Spreektijd: 75 sec

---

# 3. SCD2 in 1 Slide

In models/intermediate/int_plaatsingen_scd2.sql:
- Elke wijziging wordt een nieuwe versie
- valid_from / valid_to bepalen geldigheid in de tijd
- is_actief_versie markeert exact 1 actuele versie

Impact:
- Historische analyse blijft mogelijk
- Correcties overschrijven niets, maar worden netjes geversioneerd

Spreektijd: 90 sec

---

# 4. Mart Voor Rapportage

In models/marts/mart_beschermende_plaatsingen.sql:
- Incremental + merge voor performance
- Alleen actieve, niet-ingetrokken records
- Verrijkingen zoals:
  - duur_plaatsing_dagen
  - duur_categorie
  - diagnose_hoofdgroep
  - kwartaal_label

Impact:
- Snelle dashboard-queries
- Direct bruikbare indicatoren voor toezicht

Spreektijd: 75 sec

---

# 5. Kwaliteitsborging

Tests in tests/:
- assert_einddatum_na_startdatum.sql
- assert_geen_dubbele_actieve_versies.sql

Wat dit afvangt:
- Onmogelijke datumlogica
- Fouten in SCD2 (meerdere actieve versies)

Resultaat:
- Betrouwbare output en vroegtijdige foutdetectie

Spreektijd: 75 sec

---

# 6. Live Demo Script (2 minuten)

Commands:
- dbt deps
- dbt run
- dbt test
- dbt docs generate && dbt docs serve

Wat ik laat zien:
- Succesvolle run + tests
- Lineage van staging -> intermediate -> mart
- Eindtabel met actuele plaatsingen en KPI's

Spreektijd: 120 sec

---

# 7. Afsluiting

Businesswaarde voor IGJ:
- Betrouwbare kwartaalrapportage
- Inzicht in correcties door de tijd
- Minder handmatig controlewerk

Volgende stap:
- Uitbreiden met extra tests en BI-exposures

Bedankt. Vragen?

Spreektijd: 45 sec
