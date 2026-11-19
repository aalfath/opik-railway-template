#!/bin/bash
# Builds the database URLs from Railway reference variables, waits for the data services,
# runs the MySQL and ClickHouse migrations, then starts the backend (as upstream's compose does).
set -euo pipefail
: "${MYSQL_HOST:?MYSQL_HOST is required}"
: "${CLICKHOUSE_HOST:?CLICKHOUSE_HOST is required}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
export STATE_DB_URL="${STATE_DB_URL:-${MYSQL_HOST}:${MYSQL_PORT}/${STATE_DB_DATABASE_NAME}?createDatabaseIfNotExist=true&rewriteBatchedStatements=true&connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true}"
export ANALYTICS_DB_HOST="$CLICKHOUSE_HOST"
export ANALYTICS_DB_MIGRATIONS_URL="${ANALYTICS_DB_MIGRATIONS_URL:-jdbc:clickhouse://${CLICKHOUSE_HOST}:${ANALYTICS_DB_PORT}}"
export ANALYTICS_DB_MIGRATIONS_USER="${ANALYTICS_DB_MIGRATIONS_USER:-$ANALYTICS_DB_USERNAME}"
export ANALYTICS_DB_MIGRATIONS_PASS="${ANALYTICS_DB_MIGRATIONS_PASS:-$ANALYTICS_DB_PASS}"
export SERVER_APPLICATION_PORT="${PORT:-8080}"

wait_for() { # host port name
  local n=0
  until (exec 3<>"/dev/tcp/$1/$2") 2>/dev/null; do
    n=$((n+1))
    if [ "$n" -ge 180 ]; then echo "opik-backend: gave up waiting for $3 ($1:$2)" >&2; exit 1; fi
    echo "opik-backend: waiting for $3 ($1:$2)"
    sleep 2
  done
}
wait_for "$MYSQL_HOST" "$MYSQL_PORT" MySQL
wait_for "$CLICKHOUSE_HOST" "$ANALYTICS_DB_PORT" ClickHouse
# ClickHouse's ON CLUSTER migrations need ZooKeeper.
if [ -n "${ZOOKEEPER_HOST:-}" ]; then wait_for "$ZOOKEEPER_HOST" "${ZOOKEEPER_PORT:-2181}" ZooKeeper; fi
if [ -n "${REDIS_HOST:-}" ]; then wait_for "$REDIS_HOST" "${REDIS_PORT:-6379}" Redis; fi
# ClickHouse answers TCP before it is ready for DDL; wait for /ping as well.
n=0
until curl -fsS "http://${CLICKHOUSE_HOST}:${ANALYTICS_DB_PORT}/ping" >/dev/null 2>&1; do
  n=$((n+1)); [ "$n" -ge 90 ] && { echo "opik-backend: ClickHouse /ping never answered" >&2; exit 1; }
  sleep 2
done

cd /opt/opik
./run_db_migrations.sh
./provision_agent_insights_readonly_user.sh
exec ./entrypoint.sh
