# Opik backend (Java). Waits for MySQL, ClickHouse and Redis, runs both schema migrations, then starts.
FROM ghcr.io/comet-ml/opik/opik-backend:2.2.151@sha256:6dc4328e508421d520a6c1f2fe1110b76df674886f086e368198f497eda0ae8c
COPY --chmod=755 railway-start.sh /opt/opik/railway-start.sh
ENV PORT=8080 \
    STATE_DB_PROTOCOL=jdbc:mysql:// \
    STATE_DB_DATABASE_NAME=opik \
    ANALYTICS_DB_PROTOCOL=HTTP \
    ANALYTICS_DB_PORT=8123 \
    ANALYTICS_DB_DATABASE_NAME=opik \
    JAVA_OPTS="-Dliquibase.propertySubstitutionEnabled=true -XX:+UseG1GC -Xms256m -Xmx1g" \
    OPIK_USAGE_REPORT_ENABLED=false \
    OPIK_OTEL_SDK_ENABLED=false \
    IS_MINIO=true \
    S3_BUCKET=public \
    S3_REGION=us-east-1 \
    TOGGLE_OPIK_AI_ENABLED=false \
    TOGGLE_GUARDRAILS_ENABLED=false \
    TOGGLE_WELCOME_WIZARD_ENABLED=true \
    TOGGLE_ANNOTATION_QUEUE_AUTOMATION_ENABLED=true \
    TOGGLE_OLLIE_ENABLED=false \
    LLM_PROVIDER_TOKEN_AUTH_DESTINATION_GUARD=relaxed \
    LLM_PROVIDER_DESTINATION_GUARD=relaxed \
    LLM_PROVIDER_DESTINATION_SCHEME=plaintext_or_tls \
    LLM_PROVIDER_VIDEO_URL_DESTINATION_GUARD=relaxed \
    ANALYTICS_DB_CLUSTER_HEALTH_CHECK_ENABLED=false \
    ANALYTICS_DB_COLD_STORAGE_DISK_HEALTH_CHECK_ENABLED=false \
    CORS=false
CMD ["/opt/opik/railway-start.sh"]
