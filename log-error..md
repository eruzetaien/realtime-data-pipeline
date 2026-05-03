| Cause | Message | Solution |
|----------|----------|----------|
| CREATE TABLE | ERROR:  permission denied for schema public | psql -U postgres -d art_commission;GRANT CREATE ON SCHEMA public TO my_username; |
|podman pull apache/kafka:4.1.2|Error: short-name "apache/kafka:4.1.2" did not resolve to an alias and no unqualified-search registries are defined in "/etc/containers/registries.conf"|specify the registry, podman pull docker.io/apache/kafka:4.1.2|