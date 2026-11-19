#!/bin/sh
# Same gunicorn command as upstream's entrypoint.sh, but bound to [::] so Railway's IPv6
# private network (and IPv4) can reach it.
set -e
PORT="${PORT:-8000}"
export PYTHON_BACKEND_PORT="$PORT"
# The RQ worker threads give up if Redis is not reachable at start, so wait for it first.
python3 - <<'PY'
import os, socket, sys, time
from urllib.parse import urlparse
u = urlparse(os.environ.get("REDIS_URL", ""))
if not u.hostname:
    sys.exit(0)
for _ in range(150):
    try:
        socket.create_connection((u.hostname, u.port or 6379), timeout=3).close()
        sys.exit(0)
    except OSError:
        print(f"opik-python-backend: waiting for Redis ({u.hostname})", flush=True)
        time.sleep(2)
sys.exit("opik-python-backend: Redis never answered")
PY
echo "opik-python-backend: executor strategy $PYTHON_CODE_EXECUTOR_STRATEGY, port $PORT"
exec gunicorn --access-logfile '-' \
  --workers 1 \
  --threads "${PYTHON_CODE_EXECUTOR_PARALLEL_NUM:-5}" \
  --worker-class gthread \
  --bind "[::]:$PORT" \
  --chdir ./src 'opik_backend:create_app()'
