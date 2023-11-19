FROM python:3.10-slim

WORKDIR /code
COPY ["Pipfile", "Pipfile.lock", "/code/"]

RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy
COPY ./app /code/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
