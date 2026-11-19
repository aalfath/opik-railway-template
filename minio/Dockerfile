# MinIO stores Opik's attachments (same image upstream's compose uses). Runs as root so it can
# use Railway's root-owned volume.
FROM cloudpirates/image-minio:RELEASE.2025-10-15T17-29-55Z-hardened@sha256:8dc02a7e509336c8bbb67962086d691bdcde20a2c9327ed68e5081a681f6dbfc
USER root
COPY --chmod=755 railway-start.sh /railway-start.sh
ENV PORT=9000 \
    MINIO_BUCKET=public \
    MC_CONFIG_DIR=/tmp/.mc
ENTRYPOINT ["/railway-start.sh"]
