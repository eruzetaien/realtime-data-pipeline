## Postgres

``` bash
sudo pacman -S postgresql
sudo -u postgres initdb --locale en_US.UTF-8 -D /var/lib/postgres/data
```

The `--locale` parameter in the `initdb` command is used to specify the **locale** settings for the PostgreSQL database cluster. A locale defines the rules for character classification, sorting, and formatting of data (e.g., dates, numbers, currencies) based on a particular language and region.

```bash
sudo systemctl start postgresql
```

```bash
sudo -i -u postgres
psql
```
- **`-i`**: Start an interactive login shell, setting up the environment as if the `postgres` user logged in directly.
- **`-u postgres`**: Execute the command as the `postgres` user, which is the user typically responsible for managing PostgreSQL databases.


```bash
psql -U postgres
psql -U my_username -d art_commission
```

```sql
\dt -- check table
\c <database_name>
SHOW config_file;
SHOW listen_addresses;
SELECT * FROM pg_hba_file_rules;
ALTER SYSTEM SET wal_level = logical;
ALTER ROLE my_username REPLICATION;
SELECT * FROM pg_replication_slots;
SELECT * FROM pg_publication;
```


## Kafka

```bash
sudo pacman -S podman
podman ps -a
podman pull docker.io/apache/kafka:4.1.2
podman run -p 9092:9092 apache/kafka:4.1.2
podman start <container_id>
podman exec -it <container_id> bash
podman logs -f <container_id>
```
```bash
find / -name kafka-topics.sh 2>/dev/null
```
- `find` → search files/dirs  
- `/` → start from root  
- `-name kafka-topics.sh` → match exact filename  
- `2>/dev/null` → hide error output (stderr)

Search entire filesystem for `kafka-topics.sh` and ignore errors.

```bash
/opt/kafka/bin/kafka-topics.sh --create --topic transaction-events --bootstrap-server localhost:9092
alias kafka-topics="/opt/kafka/bin/kafka-topics.sh"
alias kafka-console-producer="/opt/kafka/bin/kafka-console-producer.sh"
alias kafka-console-consumer="/opt/kafka/bin/kafka-console-consumer.sh"
kafka-topics --bootstrap-server localhost:9092 --list
kafka-console-producer --topic transaction-events --bootstrap-server localhost:9092
kafka-console-consumer --topic transaction-events --from-beginning --bootstrap-server localhost:9092
```

```bash
podman run -it --rm -p 9092:9092 -p 29092:29092 \
  --name kafka --hostname kafka \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_PROCESS_ROLES=broker,controller \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
  -e KAFKA_LISTENERS=INTERNAL://0.0.0.0:29092,EXTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093 \
  -e KAFKA_ADVERTISED_LISTENERS=INTERNAL://host.containers.internal:29092,EXTERNAL://localhost:9092 \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT \
  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
  -e KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  apache/kafka:4.1.2

podman run -it --rm -p 8083:8083 \
  --name connect \
  -e BOOTSTRAP_SERVERS=host.containers.internal:29092 \
  -e CONFIG_STORAGE_TOPIC=my_connect_configs \
  -e OFFSET_STORAGE_TOPIC=my_connect_offsets \
  -e STATUS_STORAGE_TOPIC=my_connect_statuses \
  quay.io/debezium/connect:3.5

```

## ClickHouse
```bash
curl https://clickhouse.com/cli | sh
echo 'export PATH="/home/<myuser>/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
chctl
clickhousectl local install lts
clickhousectl local server start
clickhousectl local server list
clickhousectl local client
clickhousectl local server stop default
```

```sql
SHOW DATABASES;
USE art_commission;
SELECT currentDatabase();
SHOW TABLES;
SELECT * FROM system.kafka_consumers;
```

```bash
python3 -m venv venv
source venv/bin/activate
which pip # check if pip pointed to venv 
pip install psycopg2-binary
pip install clickhouse-connect
pip install pandas
pip install tabulate
python xprmt.py
pip freeze > requirements.txt
```