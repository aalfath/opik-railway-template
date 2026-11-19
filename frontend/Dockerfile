# Opik web UI (nginx) with a Railway start script: listens on $PORT, proxies /api to the
# backend over Railway's private network and puts the UI and API behind a login.
FROM ghcr.io/comet-ml/opik/opik-frontend:2.2.151@sha256:25369d237fffd4a2b0a949a9138d7ce623a1ee14a12c367883e0ec4159048487
COPY --chmod=755 railway-start.sh /railway-start.sh
ENV PORT=5173 \
    OPIK_AUTH_USER=opik \
    OTEL_TRACE=off
ENTRYPOINT ["/railway-start.sh"]
