#!/bin/sh
# Same gunicorn command as upstream's entrypoint.sh, but bound to [::] so Railway's IPv6
# private network (and IPv4) can reach it.
set -e
PORT="${PORT:-8000}"
export PYTHON_BACKEND_PORT="$PORT"
echo "opik-python-backend: executor strategy $PYTHON_CODE_EXECUTOR_STRATEGY, port $PORT"
exec gunicorn --access-logfile '-' \
  --workers 1 \
  --threads "${PYTHON_CODE_EXECUTOR_PARALLEL_NUM:-5}" \
  --worker-class gthread \
  --bind "[::]:$PORT" \
  --chdir ./src 'opik_backend:create_app()'
