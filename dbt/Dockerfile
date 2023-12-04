FROM python:3.10-slim as test
WORKDIR "/usr/app"
COPY my_finances /usr/app
ENTRYPOINT ["/bin/bash", "/usr/app/entrypoint.test.sh"]

FROM ghcr.io/dbt-labs/dbt-postgres:1.6.6
WORKDIR "/usr/app"
ENTRYPOINT ["/bin/bash", "/usr/app/entrypoint.sh"]
