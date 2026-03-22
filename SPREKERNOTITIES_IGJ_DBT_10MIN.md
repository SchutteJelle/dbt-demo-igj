# Sprekersnotities - IGJ dbt Demo (10 minuten)

Gebruik dit als spreekscript bij PRESENTATIE_IGJ_DBT_10MIN.md.
Doel: compact, helder verhaal voor beleidsmatige en technische stakeholders.

## Slide 1 - Titel (45-60 sec)

Kernboodschap:
- Vandaag laat ik zien hoe we kwartaaldata over beschermende plaatsingen betrouwbaar omzetten naar rapportage-data met dbt.
- De focus ligt op drie dingen: actualiteit, historie en datakwaliteit.

Spreektekst (kort):
- "In 10 minuten neem ik jullie mee van brondata naar een betrouwbare rapportagelaag."
- "Aan het einde is duidelijk waarom correcties uit latere kwartalen geen probleem meer zijn."

## Slide 2 - Probleem (75 sec)

Kernboodschap:
- De bron verandert over tijd: records worden gecorrigeerd of ingetrokken.
- Zonder goede modellering krijg je tegenstrijdige cijfers.

Spreektekst (kort):
- "IGJ wil niet alleen de laatste stand zien, maar ook begrijpen wat er is aangepast en wanneer."
- "Dat vraagt om versiebeheer op dataniveau, niet alleen in code."

Brug naar volgende slide:
- "Daarom gebruiken we een duidelijke 3-lagenarchitectuur in dbt."

## Slide 3 - 3 Lagen (75 sec)

Kernboodschap:
- Staging: technisch opschonen, geen businessregels.
- Intermediate: SCD2 voor versie- en geldigheidslogica.
- Mart: actuele data plus KPI-velden voor dashboarding.

Spreektekst (kort):
- "Door die scheiding blijft elk model begrijpelijk, testbaar en onderhoudbaar."
- "En we kunnen gericht fouten lokaliseren per laag."

## Slide 4 - SCD2 (90 sec)

Kernboodschap:
- Correcties overschrijven oude data niet; ze maken een nieuwe versie.
- valid_from en valid_to maken tijdreizen in analyses mogelijk.

Spreektekst (kort):
- "Als een zorgaanbieder in Q2 een Q1-record corrigeert, bewaren we beide versies."
- "is_actief_versie zorgt dat er precies één huidige waarheid is per bronrecord."

Publiekshaak:
- "Dit is precies wat je wilt voor toezicht: transparant en auditeerbaar."

## Slide 5 - Mart en KPI's (75 sec)

Kernboodschap:
- De mart is snel en direct bruikbaar voor rapportages.
- Alleen actieve, niet-ingetrokken records komen in de eindlaag.

Spreektekst (kort):
- "We voegen direct nuttige velden toe zoals duur in dagen, duurcategorie en kwartaal-labels."
- "Dat scheelt veel werk in BI-tools en maakt definities eenduidig."

## Slide 6 - Kwaliteitsborging (75 sec)

Kernboodschap:
- Twee kritieke regels zijn als dbt-tests afgedwongen.
- Fouten worden vroeg zichtbaar in plaats van pas in dashboards.

Spreektekst (kort):
- "Test 1: einddatum mag niet voor startdatum liggen."
- "Test 2: er mag nooit meer dan één actieve versie per record bestaan."

Brug naar demo:
- "Ik laat nu in 2 minuten zien hoe dit operationeel draait."

## Slide 7 - Demo + Afsluiting (165 sec totaal)

Demo-flow (120 sec):
- dbt deps
- dbt run
- dbt test
- dbt docs generate && dbt docs serve

Wat je hardop benoemt tijdens demo:
- "Run geslaagd: modellen opgebouwd per laag."
- "Tests geslaagd: kernkwaliteitsregels geborgd."
- "In docs zien we lineage van staging naar mart."

Afsluiting (45 sec):
- "Resultaat: betrouwbaardere kwartaalrapportage, inzicht in correcties door de tijd en minder handmatige controles."
- "Logische vervolgstap: extra tests en BI-exposures toevoegen."

## Q&A spiekbrief (optioneel)

Vraag: Waarom geen snapshots gebruikt?
Antwoord:
- "Kan, maar hier is gekozen voor expliciete SCD2-logica in SQL voor maximale controle en uitlegbaarheid per kwartaalcorrectie."

Vraag: Wat levert incremental op?
Antwoord:
- "Kortere runtimes en lagere belasting, omdat alleen nieuwe of gewijzigde records worden verwerkt."

Vraag: Hoe borgen we vertrouwen in cijfers?
Antwoord:
- "Met transparante modelstappen, versiehistorie en expliciete data tests bij elke run."
