# DBT Live Demo — Docker Setup

Een volledig zelfstandige DBT demo-omgeving op basis van **PostgreSQL** en **Docker Compose**.
Hiermee kun je de volledige DBT pipeline (`seed → run → test → docs`) live demonstreren zonder
dat je iets op je laptop hoeft te installeren behalve Docker.

---

## Inhoud

```
docker-demo/
├── docker-compose.yml          # Orchestratie: postgres + dbt container
├── .env.example                # Sjabloon voor omgevingsvariabelen
├── run_demo.sh                 # Alles-in-één demo script
└── dbt/
    ├── Dockerfile              # DBT image (python:3.12-slim + dbt-postgres)
    ├── profiles.yml            # Verbindingsprofiel (leest env-vars)
    ├── dbt_project.yml         # Projectconfiguratie
    ├── packages.yml            # dbt_utils package
    ├── seeds/
    │   └── beschermende_plaatsingen.csv   # Demo data (26 records, 3 kwartalen)
    ├── models/
    │   ├── staging/            # stg_beschermende_plaatsingen (view)
    │   ├── intermediate/       # int_plaatsingen_scd2 (table, SCD2 logica)
    │   └── marts/              # mart_beschermende_plaatsingen (incremental)
    └── tests/
        ├── assert_einddatum_na_startdatum.sql
        └── assert_geen_dubbele_actieve_versies.sql
```

### Demo data kenmerken

| Kenmerk | Detail |
|---|---|
| Zorgaanbieders | 5 (AGB-codes 06010001 – 06050005) |
| Machtigingsvormen | IBS, RM, ZM |
| Kwartalen | 2023Q1 t/m 2024Q3 |
| Correcties (SCD2) | BP001 en BP003 hebben elk 2 versies |
| Intrekking | BP008 is ingetrokken in 2024Q3 |

---

## Vereisten

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (of Docker Engine + Compose plugin)
- Poort **5432** vrij op de host (aanpasbaar via `.env`)

---

## Snel starten

```bash
# 1. Ga naar de docker-demo map
cd docker-demo

# 2. (Optioneel) pas credentials aan
cp .env.example .env

# 3. Start de volledige demo in één commando
chmod +x run_demo.sh
./run_demo.sh
```

Het script voert achtereenvolgens uit:

| Stap | Commando | Wat er gebeurt |
|------|----------|----------------|
| 1 | `docker compose up -d postgres` | Start PostgreSQL |
| 2 | `dbt deps` | Downloadt dbt_utils package |
| 3 | `dbt seed` | Laadt demo CSV → `raw.beschermende_plaatsingen` |
| 4 | `dbt run` | Bouwt staging → intermediate → mart |
| 5 | `dbt test` | Controleert datakwaliteit (22 tests) |
| 6 | `dbt docs generate` | Genereert lineage documentatie |

---

## Commando's per stap (handmatig)

```bash
# Start alleen de database (op de achtergrond)
docker compose up -d postgres

# Installeer packages
docker compose run --rm dbt dbt deps

# Laad de seed data
docker compose run --rm dbt dbt seed

# Bouw alle modellen
docker compose run --rm dbt dbt run

# Voer tests uit
docker compose run --rm dbt dbt test

# Genereer documentatie site
docker compose run --rm dbt dbt docs generate

# Start de documentatie webserver (open http://localhost:8080)
docker compose run --rm -p 8080:8080 dbt dbt docs serve --host 0.0.0.0

# Interactieve shell in de dbt container
docker compose run --rm dbt bash
```

---

## Verbinding met de database

Na `docker compose up -d postgres` kun je de data inspecteren:

```bash
# Vanuit de dbt container
docker compose run --rm dbt bash -c \
  "psql -h postgres -U dbt -d igj_demo -c 'SELECT COUNT(*) FROM marts.mart_beschermende_plaatsingen;'"

# Of direct via psql op je host (als poort 5432 open staat)
psql -h localhost -U dbt -d igj_demo
```

---

## Architectuur — de drielagenopbouw

```
CSV seed data
    │
    ▼ raw.beschermende_plaatsingen
┌─────────────────────────────────┐
│  STAGING (view)                 │  ← Type-casting, normalisatie, surrogate key
│  stg_beschermende_plaatsingen   │
└─────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────┐
│  INTERMEDIATE (table)           │  ← SCD2 logica, versies, valid_from/valid_to
│  int_plaatsingen_scd2           │
└─────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────┐
│  MARTS (incremental)            │  ← Dashboard-klare kolommen, duur, categorieën
│  mart_beschermende_plaatsingen  │
└─────────────────────────────────┘
```

---

## Verschil met de productie SQL Server configuratie

| Aspect | Productie (SQL Server) | Demo (PostgreSQL) |
|--------|------------------------|-------------------|
| Adapter | `dbt-sqlserver` | `dbt-postgres` |
| `GETDATE()` | ✅ | `NOW()` |
| `DATEFROMPARTS()` | ✅ | `MAKE_DATE()` |
| `RIGHT('0…' + x, 8)` | ✅ | `LPAD(x, 8, '0')` |
| `DATEDIFF(DAY, a, b)` | ✅ | `(b::date - a::date)` |
| Incremental strategy | `merge` | `delete+insert` |

De businesslogica (SCD2, berekeningen, tests) is **volledig identiek**.

---

## Opruimen

```bash
# Stop containers, bewaar data
docker compose down

# Stop containers EN verwijder volumes (fresh start)
docker compose down -v
```
