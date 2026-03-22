---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  /* ─── Rijkshuisstijl kleuren ─── */
  :root {
    --igj-blauw:      #154273;
    --igj-lichtblauw: #007bc7;
    --igj-oranje:     #e17000;
    --igj-grijs:      #535353;
    --igj-lichtgrijs: #f3f5f7;
    --igj-wit:        #ffffff;
  }

  /* ─── Basis ─── */
  section {
    font-family: "RO Sans", "Helvetica Neue", Arial, sans-serif;
    font-size: 22px;
    color: #333333;
    background: var(--igj-wit);
    padding: 48px 64px;
  }

  /* ─── Paginanummer ─── */
  section::after {
    color: #888;
    font-size: 16px;
  }

  /* ─── Koppen ─── */
  h1 {
    color: var(--igj-blauw);
    font-size: 46px;
    font-weight: 700;
    border-bottom: 4px solid var(--igj-lichtblauw);
    padding-bottom: 12px;
    margin-bottom: 24px;
  }
  h2 {
    color: var(--igj-lichtblauw);
    font-size: 30px;
    font-weight: 600;
    margin-top: 0;
  }
  h3 {
    color: var(--igj-blauw);
    font-size: 24px;
    margin-bottom: 8px;
  }

  /* ─── Titeldia ─── */
  section.titeldia {
    background: var(--igj-blauw);
    color: var(--igj-wit);
    display: flex;
    flex-direction: column;
    justify-content: center;
  }
  section.titeldia h1 {
    color: var(--igj-wit);
    font-size: 52px;
    border-bottom: 3px solid var(--igj-oranje);
  }
  section.titeldia h2 {
    color: #cdd8e8;
    font-size: 28px;
  }
  section.titeldia p {
    color: #aabdd4;
    font-size: 18px;
    margin-top: 40px;
  }

  /* ─── Sectie-intro dia ─── */
  section.sectie {
    background: var(--igj-lichtblauw);
    color: var(--igj-wit);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
  }
  section.sectie h1 {
    color: var(--igj-wit);
    border-bottom: 3px solid rgba(255,255,255,0.4);
    font-size: 52px;
  }
  section.sectie p {
    color: rgba(255,255,255,0.85);
    font-size: 22px;
  }

  /* ─── Accentdia (oranje) ─── */
  section.accent {
    background: var(--igj-oranje);
    color: var(--igj-wit);
    display: flex;
    flex-direction: column;
    justify-content: center;
  }
  section.accent h1 {
    color: var(--igj-wit);
    border-bottom: 3px solid rgba(255,255,255,0.4);
  }

  /* ─── Twee kolommen ─── */
  .kolommen {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 40px;
    margin-top: 8px;
  }
  .kolom-links, .kolom-rechts {
    background: var(--igj-lichtgrijs);
    border-radius: 8px;
    padding: 20px 24px;
    border-left: 4px solid var(--igj-lichtblauw);
  }

  /* ─── Lijsten ─── */
  ul {
    padding-left: 24px;
    line-height: 1.8;
  }
  ul li {
    margin-bottom: 4px;
  }
  ul li::marker {
    color: var(--igj-lichtblauw);
  }

  /* ─── Code ─── */
  pre {
    background: #1e2a3a;
    border-radius: 8px;
    padding: 16px 20px;
    font-size: 16px;
    border-left: 4px solid var(--igj-oranje);
  }
  code {
    font-family: "Fira Code", "Cascadia Code", Consolas, monospace;
  }
  :not(pre) > code {
    background: #eef2f7;
    color: var(--igj-blauw);
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.9em;
  }

  /* ─── Kaarten / highlight-blokken ─── */
  .kaart {
    background: var(--igj-lichtgrijs);
    border-radius: 10px;
    padding: 18px 24px;
    margin: 8px 0;
    border-left: 5px solid var(--igj-lichtblauw);
  }
  .kaart-oranje {
    border-left-color: var(--igj-oranje);
  }
  .kaart-groen {
    border-left-color: #39870c;
  }

  /* ─── Pill-badges ─── */
  .badge {
    display: inline-block;
    background: var(--igj-lichtblauw);
    color: white;
    border-radius: 20px;
    padding: 2px 12px;
    font-size: 0.8em;
    font-weight: bold;
    margin-right: 6px;
    vertical-align: middle;
  }
  .badge-oranje { background: var(--igj-oranje); }
  .badge-groen  { background: #39870c; }
  .badge-grijs  { background: var(--igj-grijs); }

  /* ─── Pijldiagram hulp ─── */
  .pipeline {
    display: flex;
    align-items: center;
    gap: 12px;
    justify-content: center;
    margin: 24px 0;
    font-size: 20px;
    font-weight: bold;
  }
  .pipeline-stap {
    background: var(--igj-blauw);
    color: white;
    border-radius: 8px;
    padding: 10px 18px;
    text-align: center;
    min-width: 110px;
  }
  .pipeline-pijl {
    color: var(--igj-oranje);
    font-size: 28px;
  }

  /* ─── Voettekst ─── */
  footer {
    color: #999;
    font-size: 15px;
  }

  /* ─── Tabel ─── */
  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 19px;
  }
  th {
    background: var(--igj-blauw);
    color: white;
    padding: 10px 14px;
    text-align: left;
  }
  td {
    padding: 8px 14px;
    border-bottom: 1px solid #dde3ea;
  }
  tr:nth-child(even) td { background: var(--igj-lichtgrijs); }

  /* ─── Grote emoji ─── */
  .groot-icoon {
    font-size: 72px;
    text-align: center;
    display: block;
    margin: 16px 0;
  }
---

<!-- _class: titeldia -->

# Van XML naar Dashboard
## een Data Engineering demo met **dbt**

Inspectie Gezondheidszorg en Jeugd · Data Engineering

---

<!-- _footer: "IGJ · dbt Demo" -->

# Agenda

<div class="kolommen">
<div class="kolom-links">

### Inhoud
1. Het probleem dat we oplossen
2. Wat is dbt?
3. De use case — onze data
4. Architectuur: drie lagen
5. Live demo

</div>
<div class="kolom-rechts">

### Demo onderdelen
- **Staging** — data opschonen
- **Intermediate** — correcties verwerken
- **Mart** — dashboard-klare tabel
- **Tests** — kwaliteitsborging
- **Lineage** — transparantie

</div>
</div>

---

<!-- _class: sectie -->

# 1. Het Probleem

Waarom zijn losse SQL-scripts niet genoeg?

---

<!-- _footer: "IGJ · dbt Demo" -->

# Hoe ziet het er nu uit?

<span class="groot-icoon">😰</span>

<div class="kolommen">
<div class="kolom-links">

**De situatie**
- Kwartaalbestanden van 50+ zorgaanbieders
- Handmatige correcties op eerdere kwartalen
- Scripts in een map, volgorde onduidelijk
- Alleen Jan weet hoe het werkt

</div>
<div class="kolom-rechts">

**De vragen die niemand kan beantwoorden**
- Klopt dit getal in het dashboard?
- Welk script heeft deze waarde berekend?
- Wat was de waarde **vóór** de correctie?
- Wat als Jan er niet is?

</div>
</div>

---

<!-- _footer: "IGJ · dbt Demo" -->

# De Keuken Analogie

<div class="kolommen">
<div class="kolom-links">

### Zonder dbt
Losse receptjes op bierviltjes.
Elke kok kookt anders.
Niemand weet waarom het soms niet lekker smaakt.

</div>
<div class="kolom-rechts">

### Met dbt
Professionele keuken met receptenboek.
Kwaliteitscontrole vóór het uitserveren.
Elke stap gedocumenteerd en herhaalbaar.

> *"Als een gast vraagt: hoe maak je dit? — pak je gewoon het recept erbij."*

</div>
</div>

---

<!-- _class: sectie -->

# 2. Wat is dbt?

**d**ata **b**uild **t**ool

---

<!-- _footer: "IGJ · dbt Demo" -->

# dbt in één minuut

<div class="kaart">

**dbt is een open-source tool waarmee je SQL-transformaties schrijft als georganiseerde, testbare en gedocumenteerde bouwstenen.**

</div>

| Wat dbt **wel** doet | Wat dbt **niet** doet |
|---|---|
| SQL transformaties organiseren | Data verplaatsen (dat doet ADF/SSIS) |
| Volgorde automatisch bepalen | Data opslaan buiten jouw database |
| Tests uitvoeren op data | Vervangen van je database |
| Documentatie genereren | Iets nieuws leren qua SQL |
| Lineage graph bouwen | — |

---

<!-- _footer: "IGJ · dbt Demo" -->

# dbt Kernconcepten

<div class="kolommen">
<div class="kolom-links">

### Models
Gewone `.sql` bestanden.
Elk bestand = één tabel of view.

```sql
-- models/staging/stg_plaatsingen.sql
select
  bron_id           as plaatsing_id,
  cast(dtm_aanvang as date) as startdatum
from {{ source('raw', 'xml_plaatsingen') }}
```

`{{ source() }}` en `{{ ref() }}` zijn de magie — dbt bepaalt hiermee de volgorde automatisch.

</div>
<div class="kolom-rechts">

### Wat je ermee wint

<div class="kaart">
🔗 <strong>Lineage</strong> — automatische datamap
</div>
<div class="kaart" style="margin-top:10px">
✅ <strong>Tests</strong> — kwaliteitsborging ingebakken
</div>
<div class="kaart" style="margin-top:10px">
📖 <strong>Docs</strong> — documentatie = de code
</div>
<div class="kaart" style="margin-top:10px">
🔁 <strong>Git</strong> — volledige versiehistorie
</div>

</div>
</div>

---

<!-- _class: sectie -->

# 3. Onze Use Case

Beschermende plaatsingen bij de IGJ

---

<!-- _footer: "IGJ · dbt Demo" -->

# De Data Reis

<div class="pipeline">
  <div class="pipeline-stap">Zorgaanbieder</div>
  <div class="pipeline-pijl">→</div>
  <div class="pipeline-stap">XML portaal</div>
  <div class="pipeline-pijl">→</div>
  <div class="pipeline-stap">SQL Server<br><small>raw tabel</small></div>
  <div class="pipeline-pijl">→</div>
  <div class="pipeline-stap">dbt</div>
  <div class="pipeline-pijl">→</div>
  <div class="pipeline-stap">Dashboard<br><small>Power BI</small></div>
</div>

<div class="kolommen">
<div class="kolom-links">

**Wat er in de XML staat**
- Beschermende plaatsingen (Wvggz/Wzd)
- Machtigingsvorm: IBS · RM · ZM
- Start- en einddatum plaatsing
- Zorgaanbieder (AGB-code)
- Gepseudonimiseerde cliëntgegevens

</div>
<div class="kolom-rechts">

**Het probleem met kwartaaldata**
- Q1: Aanbieder levert 500 records
- Q2: Aanbieder levert 510 records
- Q2 bevat ook: **3 correcties op Q1-records**

→ Hoe verwerk je die correcties correct?

</div>
</div>

---

<!-- _footer: "IGJ · dbt Demo" -->

# De Raw Tabel — Rechtstreeks uit XML

```sql
-- SQL Server: dbo.raw_beschermende_plaatsingen
-- Elke XML-aanlevering komt hier terecht, onveranderd

raw_id                  BIGINT IDENTITY(1,1)   -- technische sleutel
bsn_geanonimiseerd      CHAR(64)               -- SHA-256 hash van BSN
zorgaanbieder_agb_code  CHAR(8)                -- AGB-register code
machtigingsvorm_code    NVARCHAR(50)           -- 'IBS', 'RM', 'ZM'
startdatum_plaatsing    DATE
einddatum_plaatsing     DATE                   -- NULL = nog actief
kwartaal_levering       CHAR(7)                -- '2024-Q3'
is_correctie            BIT                    -- 1 = correctie op eerder record
correctie_reden         NVARCHAR(500)
validatie_status_code   NVARCHAR(20)           -- 'GELDIG', 'WAARSCHUWING'
```

<div class="kaart kaart-oranje" style="margin-top:16px">

⚠️ Deze tabel raken we **nooit aan**. dbt leest er alleen uit. De raw tabel is de enige bron van waarheid.

</div>

---

<!-- _class: sectie -->

# 4. Architectuur
## Drie lagen, één doel

---

<!-- _footer: "IGJ · dbt Demo" -->

# Het Drielagenmodel

<div class="kolommen">
<div class="kolom-links">

<div class="kaart">
<span class="badge">1</span> <strong>Staging</strong><br>
<em>Opschonen &amp; standaardiseren</em><br>
→ materialized as <code>view</code><br>
→ Géén businesslogica
</div>

<div class="kaart" style="margin-top:12px">
<span class="badge">2</span> <strong>Intermediate</strong><br>
<em>SCD Type 2 versiehistorie</em><br>
→ materialized as <code>ephemeral</code><br>
→ Kwartaalcorrecties verwerken
</div>

<div class="kaart" style="margin-top:12px">
<span class="badge">3</span> <strong>Mart</strong><br>
<em>Dashboard-klare tabel</em><br>
→ materialized as <code>incremental</code><br>
→ KPI-velden, verrijkte dimensies
</div>

</div>
<div class="kolom-rechts">

**Waarom drie lagen?**

Elke laag heeft **één verantwoordelijkheid**.

| Vraag | Antwoord |
|---|---|
| Wat heb ik ontvangen? | Raw |
| Hoe ziet het er netjes uit? | Staging |
| Wat betekent het? | Intermediate |
| Wat wil het dashboard zien? | Mart |

> *Scheiding van "wat is er aangeleverd" en "wat betekent het" is cruciaal bij audits.*

</div>
</div>

---

<!-- _class: sectie -->

# 5. Live Demo

Laten we het in actie zien

---

<!-- _footer: "IGJ · dbt Demo" -->

# Stap 1 — dbt debug

```bash
dbt debug
```

<div class="kaart kaart-groen" style="margin-top:16px">

✅ Verbinding met SQL Server getest<br>
✅ Configuratie gecontroleerd<br>
✅ Alle packages aanwezig

</div>

> *"Dit is altijd je eerste commando. Net als vragen of de stekker erin zit."*

---

<!-- _footer: "IGJ · dbt Demo" -->

# Stap 2 — Staging Model

```bash
dbt run --select staging
```

```sql
-- models/staging/stg_beschermende_plaatsingen.sql

with brondata as (
    select * from {{ source('igj_raw', 'raw_beschermende_plaatsingen') }}
),
opgeschoond as (
    select
        {{ dbt_utils.generate_surrogate_key(
            ['bsn_geanonimiseerd', 'zorgaanbieder_agb_code', 'startdatum_plaatsing']
        ) }}                                as plaatsing_sleutel,
        bsn_geanonimiseerd,
        upper(trim(zorgaanbieder_agb_code)) as aanbieder_code,
        machtigingsvorm_code,
        cast(startdatum_plaatsing as date)  as startdatum,
        cast(einddatum_plaatsing  as date)  as einddatum,
        kwartaal_levering,
        is_correctie,
        validatie_status_code
    from brondata
    where validatie_status_code != 'AFGEKEURD'
)
select * from opgeschoond
```

---

<!-- _footer: "IGJ · dbt Demo" -->

# Stap 3 — Kwartaalcorrecties: SCD Type 2

**Het probleem:** Q1 record is fout → Q2 levert correctie aan.
**De oplossing:** We overschrijven niet. We archiveren de oude versie.

```
Versie 1 (aangeleverd in Q1):
  plaatsing_id = X | einddatum = 2024-03-10 | valid_from = 2024-04 | valid_to = 2024-07

Versie 2 (gecorrigeerd in Q2):
  plaatsing_id = X | einddatum = 2024-03-25 | valid_from = 2024-07 | valid_to = NULL ← actueel
```

<div class="kolommen">
<div class="kolom-links">

**Voordeel voor IGJ**
- Volledige audittrail bewaard
- Reconstrueerbaar: wat wisten we op datum X?
- Patroon van correcties = kwaliteitssignaal

</div>
<div class="kolom-rechts">

```bash
dbt run --select intermediate
```

Bekijk `int_plaatsingen_scd2.sql`:
- `valid_from` — versie geldig vanaf
- `valid_to` — versie geldig tot (NULL = huidig)
- `is_actueel` — meest recente versie

</div>
</div>

---

<!-- _footer: "IGJ · dbt Demo" -->

# Stap 4 — Incremental Mart

```bash
dbt run --select mart_beschermende_plaatsingen
```

```sql
-- models/marts/mart_beschermende_plaatsingen.sql
{{
    config(
        materialized       = 'incremental',
        unique_key         = 'plaatsing_sleutel',
        incremental_strategy = 'merge'
    )
}}

select
    plaatsing_sleutel,
    aanbieder_code,
    machtigingsvorm_code,
    startdatum,
    einddatum,
    -- Berekende KPI-kolommen
    datediff(day, startdatum, coalesce(einddatum, getdate())) as plaatsingsduur_dagen,
    case when einddatum is null then 1 else 0 end             as is_actief,
    ...
from {{ ref('int_plaatsingen_scd2') }}
{% if is_incremental() %}
where aanlevering_tijdstip > (select max(aanlevering_tijdstip) from {{ this }})
{% endif %}
```

---

<!-- _footer: "IGJ · dbt Demo" -->

# Stap 5 — Tests

```bash
dbt test
```

```yaml
# models/staging/_staging_models.yml

models:
  - name: stg_beschermende_plaatsingen
    columns:
      - name: plaatsing_sleutel
        tests:
          - unique        # geen dubbele records
          - not_null      # altijd gevuld

      - name: machtigingsvorm_code
        tests:
          - accepted_values:
              values: ['IBS', 'RM', 'ZM', 'CRM', 'VRM']
```

<div class="kaart kaart-groen" style="margin-top:16px">

✅ Als een zorgaanbieder een onbekende machtigingsvorm aanlevert, <strong>weet je het vóór het dashboard het bereikt</strong>.

</div>

---

<!-- _footer: "IGJ · dbt Demo" -->

# Stap 6 — Documentatie & Lineage

```bash
dbt docs generate && dbt docs serve
```

<div class="kolommen">
<div class="kolom-links">

**Wat je ziet in de browser**
- Alle modellen met beschrijvingen
- Kolomdefinities
- Testresultaten
- **Lineage graph** ← het aha-moment

</div>
<div class="kolom-rechts">

```
raw_beschermende_plaatsingen
          │
          ▼
stg_beschermende_plaatsingen
          │
          ▼
  int_plaatsingen_scd2
          │
          ▼
mart_beschermende_plaatsingen
          │
          ▼
    Power BI Dashboard
```

</div>
</div>

> *"Een inspecteur die vraagt 'hoe komt dit getal tot stand?' — kan dit nu zelf uitzoeken."*

---

<!-- _footer: "IGJ · dbt Demo" -->

# Overzicht dbt Commando's

| Commando | Wat doet het? | Wanneer? |
|---|---|---|
| `dbt debug` | Verbinding testen | Altijd eerst |
| `dbt run` | Alle modellen bouwen | Na elke kwartaallevering |
| `dbt run --select staging` | Alleen staging bouwen | Tijdens ontwikkeling |
| `dbt run --full-refresh` | Alles herbouwen | Na logicawijziging |
| `dbt test` | Kwaliteitstests uitvoeren | Na elke run |
| `dbt docs generate` | Documentatie genereren | Na wijzigingen |
| `dbt docs serve` | Docs openen in browser | Voor review / audit |

---

<!-- _footer: "IGJ · dbt Demo" -->

# Wat Levert Dit Op voor IGJ?

<div class="kolommen">
<div class="kolom-links">

### Voor inspecteurs
- Eén betrouwbare bron van waarheid
- Transparante berekeningen
- Audittrail tot op record-niveau
- Signalering: wie corrigeert veel?

### Voor analisten
- Geen handmatig SQL meer draaien
- Correcties worden automatisch verwerkt
- Documentatie altijd up-to-date

</div>
<div class="kolom-rechts">

### Voor het datateam
- Code in Git — versiehistorie
- Tests vangen fouten vroegtijdig
- Nieuwe collega's sneller productief
- "Jan weg" is geen risico meer

### Voor auditors
- Volledige lineage aantoonbaar
- Elke transformatiestap leesbaar
- Reproduceerbaar op elk moment

</div>
</div>

---

<!-- _class: accent -->

# Drie Aha-Momenten

1. **"Het is gewoon SQL"** — geen nieuwe taal te leren
2. **"De documentatie schrijft zichzelf"** — dbt genereert het uit de code
3. **"Ik zie hoe de data stroomt"** — de lineage graph maakt alles zichtbaar

---

<!-- _footer: "IGJ · dbt Demo" -->

# Veelgestelde Vragen

**Moeten we onze ETL-tool weggooien?**
Nee. ADF/SSIS laadt data naar SQL Server. dbt transformeert daarna. Ze vullen elkaar aan.

**Is dbt niet te technisch voor analisten?**
dbt werkt met SQL — wat analisten al kennen. YAML-bestanden zijn leesbaar als een lijst. Drempel is bewust laag.

**Hoe zit het met AVG en privacygevoelige data?**
dbt transformeert data in jullie eigen beveiligde SQL Server. In de staging layer worden BSN-hashes aangemaakt — downstream modellen zien nooit het ruwe BSN.

**Wat als een model crasht halverwege?**
dbt werkt atomisch: de productietabel wordt pas vervangen als alles geslaagd is. Gefaalde modellen blokkeren downstream modellen automatisch.

---

<!-- _class: titeldia -->

# Vragen?

## dbt documentatie: **docs.getdbt.com**

Projectbestanden staan in deze map:
`models/staging/` · `models/intermediate/` · `models/marts/`

*Inspectie Gezondheidszorg en Jeugd · Data Engineering Demo*
