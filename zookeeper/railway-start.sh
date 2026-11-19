#!/bin/bash
# Creates the data directories on the volume and serves the AdminServer on $PORT,
# then runs the image's entrypoint (which drops to the zookeeper user).
set -euo pipefail
mkdir -p "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR"
export ZOO_CFG_EXTRA="admin.serverPort=${PORT:-8080} ${ZOO_CFG_EXTRA:-}"
# zoo.cfg is regenerated on every start so a changed PORT takes effect.
rm -f "$ZOO_CONF_DIR/zoo.cfg"
exec /docker-entrypoint.sh "$@"
