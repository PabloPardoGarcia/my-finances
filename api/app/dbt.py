import json
import os

import requests

DBT_SERVER_HOST = os.getenv("DBT_SERVER_HOST")
DBT_SERVER_PORT = os.getenv("DBT_SERVER_PORT")
DBT_SERVER_URL = f"http://{DBT_SERVER_HOST}:{DBT_SERVER_PORT}/dbt"


def run():
    headers = {
        "Content-Type": "application/json",
    }

    result = requests.post(url=DBT_SERVER_URL, headers=headers, json={"cmd": "dbt run"})
    result.raise_for_status()
