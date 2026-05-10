FROM quay.io/debezium/connect:3.5

USER root

RUN mkdir -p /kafka/connect/clickhouse

ADD https://github.com/ClickHouse/clickhouse-kafka-connect/releases/download/v1.3.7/clickhouse-kafka-connect-v1.3.7.zip /tmp/clickhouse.zip

RUN unzip /tmp/clickhouse.zip -d /kafka/connect/clickhouse

USER kafka