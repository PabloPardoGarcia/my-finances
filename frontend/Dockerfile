FROM python:3.10-slim

WORKDIR /code
COPY ["Pipfile", "Pipfile.lock", "/code/"]

RUN pip install pipenv --no-cache-dir && \
    pipenv install --system --deploy && \
    mkdir /code/.streamlit

COPY app /code/app
COPY config.toml /code/.streamlit/config.toml

CMD ["streamlit", "run", "app/main.py"]
