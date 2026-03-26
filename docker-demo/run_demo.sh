#!/usr/bin/env bash
# =============================================================================
# run_demo.sh
# Voert de volledige DBT live-demo uit van begin tot eind.
#
# Gebruik:
#   chmod +x run_demo.sh
#   ./run_demo.sh
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

step() {
  echo -e "\n${CYAN}══════════════════════════════════════════════${NC}"
  echo -e "${GREEN}▶  $1${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════${NC}\n"
}

step "1/6 · Start PostgreSQL"
docker compose up -d postgres
echo -e "${YELLOW}Wacht tot PostgreSQL klaar is...${NC}"
docker compose run --rm dbt bash -c "until pg_isready -h postgres -U dbt; do sleep 1; done"

step "2/6 · Installeer DBT packages  (dbt deps)"
docker compose run --rm dbt dbt deps

step "3/6 · Laad demo-data  (dbt seed)"
docker compose run --rm dbt dbt seed

step "4/6 · Bouw alle modellen  (dbt run)"
docker compose run --rm dbt dbt run

step "5/6 · Voer datakwaliteitstests uit  (dbt test)"
docker compose run --rm dbt dbt test

step "6/6 · Genereer documentatie  (dbt docs generate)"
docker compose run --rm dbt dbt docs generate

echo -e "\n${GREEN}✅ Demo voltooid!${NC}"
echo -e "   Bekijk de gegenereerde documentatie met:"
echo -e "   ${YELLOW}docker compose run --rm -p 8080:8080 dbt dbt docs serve --host 0.0.0.0${NC}"
echo -e "   Open daarna: http://localhost:8080\n"
