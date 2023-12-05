FROM python:3.10-slim as base

COPY my_finances /code
COPY profiles.yml /root/.dbt/
COPY ["Pipfile", "Pipfile.lock", "/code/"]

FROM base as test
WORKDIR "/code"
COPY [".yamllint", ".sqlfluff", "/code/"]
RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy --dev

ENTRYPOINT ["/bin/bash", "/code/entrypoint.test.sh"]

FROM base
WORKDIR "/code"
COPY server /code/server
RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy
ENTRYPOINT ["/bin/bash", "/code/entrypoint.sh"]
