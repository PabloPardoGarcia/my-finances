import requests
from io import BytesIO

API_URL = "http://my-finances-api"


def upload(uploaded_file: BytesIO, table_name: str) -> requests.Response:
    files = {
        "file": (uploaded_file.name, uploaded_file.read(), "text/csv"),
    }
    payload = {"table_name": f"sources.{table_name}"}
    return requests.post(
        url=f"{API_URL}/upload", files=files, data=payload
    )


def get_transactions(skip: int = 0, limit: int = 100) -> requests.Response:
    payload = {"skip": skip, "limit": limit}
    return requests.get(
        url=f"{API_URL}/transactions",
        data=payload
    )
