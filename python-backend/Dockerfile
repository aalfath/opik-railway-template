# Opik Python backend: runs Python evaluation metrics and the optimizer worker.
# Railway has no privileged containers, so code runs in the "process" executor, not Docker-in-Docker.
FROM ghcr.io/comet-ml/opik/opik-python-backend:2.2.151@sha256:bdb132cd11736cfd48c51d83ad0f52becf59c43d33b3d6e3987cd53b82f0fe3e
COPY --chmod=755 railway-start.sh /opt/opik-python-backend/railway-start.sh
ENV PORT=8000 \
    PYTHON_CODE_EXECUTOR_STRATEGY=process \
    PYTHON_CODE_EXECUTOR_PARALLEL_NUM=5 \
    PYTHON_CODE_EXECUTOR_EXEC_TIMEOUT_IN_SECS=3 \
    PYTHON_CODE_EXECUTOR_ALLOW_NETWORK=false \
    RQ_WORKER_ENABLED=true \
    OPIK_OTEL_SDK_ENABLED=false
CMD ["./railway-start.sh"]
