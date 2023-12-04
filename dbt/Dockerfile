FROM python:3.10-slim as test
WORKDIR "/code"
COPY my_finances /code
COPY ["Pipfile", "Pipfile.lock", ".yamllint", "/code/"]

RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy --dev

ENTRYPOINT ["/bin/bash", "/code/entrypoint.test.sh"]

FROM ghcr.io/dbt-labs/dbt-postgres:1.6.6
WORKDIR "/usr/app"
ENTRYPOINT ["/bin/bash", "/usr/app/entrypoint.sh"]
