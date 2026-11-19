#!/bin/sh
# Writes the parts of Opik's ClickHouse config that depend on the deployment (ZooKeeper address,
# HTTP port, cluster credentials), then runs the image's own entrypoint.
set -eu
: "${CLICKHOUSE_PASSWORD:?CLICKHOUSE_PASSWORD is required}"
: "${ZOOKEEPER_HOST:?ZOOKEEPER_HOST is required}"
ZOOKEEPER_PORT="${ZOOKEEPER_PORT:-2181}"
cat > /etc/clickhouse-server/config.d/opik-railway.xml <<XML
<clickhouse>
    <http_port>${PORT:-8123}</http_port>
    <zookeeper>
        <node>
            <host>${ZOOKEEPER_HOST}</host>
            <port>${ZOOKEEPER_PORT}</port>
        </node>
    </zookeeper>
    <!-- Single-node cluster as in upstream; Distributed reads and writes log in as the Opik user. -->
    <remote_servers>
        <cluster>
            <shard>
                <internal_replication>true</internal_replication>
                <replica>
                    <host>localhost</host>
                    <port>9000</port>
                    <user>${CLICKHOUSE_USER}</user>
                    <password>${CLICKHOUSE_PASSWORD}</password>
                </replica>
            </shard>
        </cluster>
    </remote_servers>
</clickhouse>
XML
echo "clickhouse: ZooKeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}, HTTP port ${PORT:-8123}"
exec /entrypoint.sh
