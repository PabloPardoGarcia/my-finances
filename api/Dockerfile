FROM python:3.10-slim as base

WORKDIR /code
COPY ["Pipfile", "Pipfile.lock", "/code/"]

FROM base as test
WORKDIR /code
RUN pip install pipenv --no-cache-dir && \
    pipenv install --dev --system --deploy
COPY app /code/app
COPY tests /code/tests
CMD ["pytest", "tests/", "-v"]

FROM base
WORKDIR /code
RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy
COPY app /code/app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]