#!/bin/sh
# Starts MinIO on $PORT, creates Opik's bucket once it answers, then waits on the server.
set -eu
: "${MINIO_ROOT_USER:?MINIO_ROOT_USER is required}"
: "${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"
PORT="${PORT:-9000}"
mkdir -p /data
minio server /data --address ":${PORT}" --console-address ":9001" &
pid=$!
trap 'kill -TERM "$pid" 2>/dev/null' TERM INT
i=0
until mc alias set local "http://127.0.0.1:${PORT}" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" --api S3v4 >/dev/null 2>&1; do
  i=$((i+1)); [ "$i" -ge 60 ] && { echo "minio: server did not answer" >&2; exit 1; }
  sleep 1
done
mc mb --ignore-existing "local/${MINIO_BUCKET}"
mc anonymous set download "local/${MINIO_BUCKET}/" >/dev/null
echo "minio: bucket ${MINIO_BUCKET} ready"
wait "$pid"
