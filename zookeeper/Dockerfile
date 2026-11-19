# ZooKeeper coordinates ClickHouse's replicated tables and ON CLUSTER migrations (as in upstream's compose).
FROM zookeeper:3.9.4@sha256:dfa9ba46d14bd52bcb3c1dac3ba91f179cf4cebf7ee576e1c2df09c68fc1d30d
COPY --chmod=755 railway-start.sh /railway-start.sh
# The AdminServer on PORT answers /commands/ruok for Railway's health check.
ENV JVMFLAGS="-Xmx512m" \
    ZOO_4LW_COMMANDS_WHITELIST="srvr,ruok" \
    ZOO_DATA_DIR=/data/data \
    ZOO_DATA_LOG_DIR=/data/datalog \
    ZOO_ADMINSERVER_ENABLED=true \
    PORT=8080
ENTRYPOINT ["/railway-start.sh"]
CMD ["zkServer.sh", "start-foreground"]
