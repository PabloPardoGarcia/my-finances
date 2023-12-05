dbt deps
dbt build
dbt docs generate
dbt docs serve --no-browser --port 8080 &
uvicorn server.main:app --host 0.0.0.0 --port 8000