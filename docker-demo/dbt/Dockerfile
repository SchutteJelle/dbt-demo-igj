# =============================================================================
# Dockerfile voor de DBT demo container
#
# Bevat dbt-core + dbt-postgres adapter.
# PostgreSQL client-tools (pg_isready) worden toegevoegd voor health-checks.
# =============================================================================

FROM python:3.12-slim

# Systeemafhankelijkheden + PostgreSQL client voor pg_isready
RUN apt-get update && apt-get install -y --no-install-recommends \
        postgresql-client \
        git \
    && rm -rf /var/lib/apt/lists/*

# Installeer DBT met PostgreSQL adapter
RUN pip install --no-cache-dir \
    dbt-core==1.8.* \
    dbt-postgres==1.8.*

WORKDIR /usr/app/dbt

# Kopieer het DBT project in de image
# (bij docker-compose wordt dit overschreven door een volume mount)
COPY . .

# Gebruik de profiles.yml uit de projectmap (niet ~/.dbt/)
ENV DBT_PROFILES_DIR=/usr/app/dbt

CMD ["dbt", "--version"]
