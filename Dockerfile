FROM ghcr.io/dbt-labs/dbt-postgres:1.6.6

ENTRYPOINT ["/bin/bash", "/usr/app/entrypoint.sh"]
