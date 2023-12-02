FROM python:3.10-slim as base

WORKDIR /code
COPY ["Pipfile", "Pipfile.lock", "/code/"]

RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy && \
    mkdir /code/.streamlit

COPY app /code/app
COPY config.toml /code/.streamlit/config.toml

FROM base as test
WORKDIR /code
COPY entrypoint.test.sh /code/entrypoint.test.sh
ENTRYPOINT ["/bin/bash", "/code/entrypoint.test.sh"]

FROM base
WORKDIR /code
CMD ["streamlit", "run", "app/main.py"]
