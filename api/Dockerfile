FROM python:3.10-slim as base

WORKDIR /code
COPY ["Pipfile", "Pipfile.lock", "/code/"]

FROM base as test
WORKDIR /code
RUN pip install pipenv --no-cache-dir && \
    pipenv install --dev --system --deploy
COPY app /code/app
COPY tests /code/tests
COPY entrypoint.test.sh /code/
ENTRYPOINT ["/bin/bash", "/code/entrypoint.test.sh"]

FROM base
WORKDIR /code
RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy
COPY app /code/app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]