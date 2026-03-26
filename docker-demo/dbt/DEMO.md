# DBT + PostgreSQL Docker Demo

Deze demo draait volledig in Docker:
- PostgreSQL als database
- dbt als runner
- dbt Docs voor lineage visualisatie

Doel van de demo:
1. Laten zien dat de pipeline end-to-end werkt op PostgreSQL.
2. Laten zien hoe data stroomt van source/seed naar staging, intermediate en marts.
3. Lineage grafisch tonen in dbt Docs.

## 1. Start PostgreSQL

```bash
docker compose up -d postgres
```

Controleer optioneel de status:

```bash
docker compose ps
```

## 2. Controleer dbt connectie

```bash
docker compose run --rm dbt "dbt debug"
```

Je wilt hier zien dat de connectie naar target `dev` succesvol is.

## 3. Draai de volledige demo-flow

```bash
docker compose run --rm dbt "dbt deps && dbt seed --full-refresh && dbt run && dbt test"
```

Wat dit doet:
1. `dbt deps`: installeert packages (zoals `dbt_utils`).
2. `dbt seed --full-refresh`: laadt de demo CSV in PostgreSQL (schema `raw`).
3. `dbt run`: bouwt modellen in lagen (`staging` -> `intermediate` -> `marts`).
4. `dbt test`: valideert kwaliteit en businessregels.

## 4. Genereer en toon lineage in dbt Docs

Genereer eerst documentatie:

```bash
docker compose run --rm dbt "dbt docs generate"
```

Start daarna de docs server vanuit Docker en expose poort 8080:

```bash
docker compose run --rm --service-ports dbt "dbt docs serve --host 0.0.0.0 --port 8080"
```

Open vervolgens in je browser:

```text
http://localhost:8080
```

In de UI kun je:
1. Op een mart-model klikken en upstream/downstream lineage tonen.
2. Zien dat afhankelijkheden via `ref()` en `source()` automatisch zijn opgebouwd.
3. Kolommen, tests en beschrijvingen per model inspecteren.

## 5. Handige demo commando's tijdens presentatie

```bash
# Voorbeelddata uit een model tonen (zonder zelf SQL client te openen)
docker compose run --rm dbt "dbt show --select int_plaatsingen_scd2 --limit 10"

# Laat zien dat raw XML wordt uitgepakt in staging
docker compose run --rm dbt "dbt seed --full-refresh --select beschermende_plaatsingen && dbt run --select stg_beschermende_plaatsingen"
docker compose run --rm dbt "dbt show --select stg_beschermende_plaatsingen --limit 10"

# Laat de ruwe XML tussenlaag zien
docker compose run --rm dbt "dbt show --select raw_xml_beschermende_plaatsingen --limit 5"

# Alleen marts bouwen
docker compose run --rm dbt "dbt run --select marts"

# Alleen 1 model + upstream
docker compose run --rm dbt "dbt run --select +int_plaatsingen_scd2"

# Alleen tests op marts
docker compose run --rm dbt "dbt test --select marts"

# Toon lineaire DAG in CLI
docker compose run --rm dbt "dbt ls --select marts --output path"
```

## 6. Korte praatplaat (hoe het werkt)

1. Seed data komt binnen in `raw` met een XML payload per record.
2. `staging` pakt XML uit en standaardiseert velden en types.
3. `intermediate` implementeert SCD2 logica voor historisering.
4. `marts` levert analyseklare tabellen/facts.
5. Tests bewaken datamodel- en businesskwaliteit.
6. dbt Docs maakt lineage zichtbaar voor technische en business stakeholders.

## 7. Opruimen

Stop containers:

```bash
docker compose down
```

Stop en verwijder ook database data:

```bash
docker compose down -v
```

## Optionele environment overrides

Je kunt onderstaande variabelen zetten in je shell of in een `.env` bestand naast `docker-compose.yml`:

- `DBT_USER` (default: `dbt`)
- `DBT_PASSWORD` (default: `dbt_demo_2024`)
- `DBT_DBNAME` (default: `igj_demo`)
- `DBT_PORT` (default: `5432`, intern in Docker netwerk)
- `POSTGRES_HOST_PORT` (default: `5433`, alleen voor lokale toegang vanaf host)
- `DBT_SCHEMA` (default: `public`)
- `DBT_THREADS` (default: `4`)
