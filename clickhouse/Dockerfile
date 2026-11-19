# ClickHouse for Opik's traces, spans and feedback scores (same version upstream's compose pins).
FROM clickhouse/clickhouse-server:26.3.62.3-alpine@sha256:1d45e52080e6ed136a6377863046a0e53d69fb0418d799f12e23184ed6460c55
COPY config.d/ /etc/clickhouse-server/config.d/
COPY users.d/ /etc/clickhouse-server/users.d/
COPY --chmod=755 railway-start.sh /railway-start.sh
ENV CLICKHOUSE_DB=opik \
    CLICKHOUSE_USER=opik \
    CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 \
    PORT=8123
ENTRYPOINT ["/railway-start.sh"]
