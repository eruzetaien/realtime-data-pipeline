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
```

```bash
sudo pacman -S podman
podman ps -a
podman pull docker.io/apache/kafka:4.1.2
podman run -p 9092:9092 apache/kafka:4.1.2
```

