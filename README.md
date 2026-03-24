# IGJ Beschermende Plaatsingen – dbt Demo

Dit project bevat een dbt-pipeline voor de verwerking van beschermende plaatsingen (Wvggz) bij IGJ. De pipeline gebruikt een drielagenarchitectuur (staging → intermediate → marts) op Microsoft SQL Server.

---

## Vereisten

| Vereiste | Versie |
|---|---|
| Python | ≥ 3.9 |
| dbt-core | ≥ 1.5 |
| dbt-sqlserver | ≥ 1.5 |
| Toegang tot een SQL Server instantie | — |

Installeer de benodigde adapter als deze nog niet aanwezig is:

```bash
pip install dbt-sqlserver
```

---

## Stap 1 – Repository klonen

```bash
git clone https://github.com/SchutteJelle/dbt-demo-igj.git
cd dbt-demo-igj
```

---

## Stap 2 – Verbinding configureren (`profiles.yml`)

dbt leest de databaseverbinding uit `~/.dbt/profiles.yml`.  
Voeg het volgende blok toe aan dat bestand (of maak het aan als het nog niet bestaat).

```yaml
igj_beschermende_plaatsingen:
  target: dev
  outputs:
    dev:
      type: sqlserver
      driver: "ODBC Driver 17 for SQL Server"   # pas aan naar de geïnstalleerde driver
      server: <server-naam-of-ip>               # bijv. localhost of mijn-server.database.windows.net
      port: 1433
      database: <database-naam>
      schema: dbt_dev                           # werkschema tijdens ontwikkeling
      authentication: sql                       # of: windows / ActiveDirectoryInteractive / ...
      username: <gebruikersnaam>
      password: <wachtwoord>
```

> **Let op:** de profielnaam (`igj_beschermende_plaatsingen`) moet exact overeenkomen met de `profile`-waarde in `dbt_project.yml`.

### Ondersteunde authenticatiemethoden

| Waarde | Omschrijving |
|---|---|
| `sql` | SQL Server-login met gebruikersnaam en wachtwoord |
| `windows` | Windows-authenticatie (Active Directory) |
| `ActiveDirectoryInteractive` | Azure AD met MFA-popup |
| `ActiveDirectoryPassword` | Azure AD met gebruikersnaam en wachtwoord |
| `ServicePrincipal` | Service Principal (client_id / client_secret) |

Zie de [dbt-sqlserver documentatie](https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup) voor alle opties.

### Verbinding testen

```bash
dbt debug
```

Een succesvolle uitvoer eindigt met:

```
All checks passed!
```

---

## Stap 3 – Packages installeren

Dit project gebruikt `dbt_utils`. Installeer externe packages met:

```bash
dbt deps
```

---

## Stap 4 – Pipeline uitvoeren

```bash
# Alle modellen draaien (staging → intermediate → marts)
dbt run

# Alleen een specifieke laag draaien
dbt run --select tag:staging
dbt run --select tag:intermediate
dbt run --select tag:marts

# Datakwaliteitstests uitvoeren
dbt test

# Documentatie bouwen en bekijken
dbt docs generate
dbt docs serve
```

---

## Projectstructuur

```
dbt-demo-igj/
├── models/
│   ├── staging/          # Ruwe data opschonen (views)
│   ├── intermediate/     # SCD Type 2 businesslogica (tables)
│   └── marts/            # Eindproducten voor dashboards (incremental)
├── tests/                # Singular tests op datakwaliteit
├── packages.yml          # Externe dbt packages (dbt_utils)
└── dbt_project.yml       # Projectconfiguratie
```

---

## Schema's

Per laag wordt een apart schema aangemaakt in de geconfigureerde database:

| Laag | Schema | Materialisatie |
|---|---|---|
| Staging | `<schema>_staging` | view |
| Intermediate | `<schema>_intermediate` | table |
| Marts | `<schema>_marts` | incremental |

Het voorvoegsel `<schema>` is de `schema`-waarde uit `profiles.yml` (standaard `dbt_dev`).

---

## Variabelen

De volgende projectvariabelen zijn instelbaar via `dbt_project.yml` of via de commandoregel:

| Variabele | Standaardwaarde | Omschrijving |
|---|---|---|
| `igj_start_datum` | `2020-01-01` | Startdatum voor initiële incrementele laad |
| `geldige_machtigingsvormen` | `['IBS', 'RM', 'ZM']` | Toegestane machtigingsvormen |

Overschrijf een variabele via de CLI:

```bash
dbt run --vars '{"igj_start_datum": "2019-01-01"}'
```

---

## Veelgestelde vragen

**De ODBC-driver ontbreekt.**  
Installeer [Microsoft ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server) of een nieuwere versie en pas de `driver`-waarde in `profiles.yml` dienovereenkomstig aan.

**`dbt debug` meldt dat het profiel niet gevonden wordt.**  
Controleer of de profielnaam in `~/.dbt/profiles.yml` exact `igj_beschermende_plaatsingen` is (hoofdlettergevoelig).

**De incrementele mart loopt vast bij de eerste run.**  
Gebruik `--full-refresh` voor de initiële laad:

```bash
dbt run --select tag:marts --full-refresh
```
