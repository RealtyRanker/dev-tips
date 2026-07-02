#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"

PG_CONTAINER="realty-postgres"
PG_USER="realty_parser"
PG_DB="realty_parser"

echo "========================================"
echo " RealtyRanker — apply migrations"
echo "========================================"
echo ""

if [ ! -d "$MIGRATIONS_DIR" ]; then
  echo "Migrations directory not found: $MIGRATIONS_DIR"
  exit 1
fi

docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 -q -c \
  "CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now());"

for migration in $(ls "$MIGRATIONS_DIR"/*.sql | sort); do
  version="$(basename "$migration")"

  applied="$(docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$PG_DB" -tA -c \
    "SELECT 1 FROM schema_migrations WHERE version = '$version';")"

  if [ "$applied" = "1" ]; then
    echo ">>> $version already applied, skipping"
    continue
  fi

  echo ">>> Applying $version"
  docker exec -i "$PG_CONTAINER" psql -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 -q < "$migration"

  docker exec "$PG_CONTAINER" psql -U "$PG_USER" -d "$PG_DB" -q -c \
    "INSERT INTO schema_migrations (version) VALUES ('$version');"
done

echo ""
echo "========================================"
echo " All migrations applied"
echo "========================================"
