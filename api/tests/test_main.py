from unittest.mock import mock_open, patch

import pytest
from fastapi.testclient import TestClient


def test_root(client: TestClient):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello world"}


@pytest.fixture
def mocked_file_content(mocker):
    mocker_file_data = mocker.mock_open(read_data="{}")
    mocker.patch("builtins.open", mocker_file_data)


def test_upload_non_csv_file(client: TestClient):
    file_content = "{'fake_key':'fake_value'}"
    with patch("builtins.open", mock_open(read_data=file_content)):
        files = {
            "file": ("fake_path.json", open("fake_path.json", "r"), "application/json")
        }
        payload = {"table_name": "fake_table"}
        response = client.post("/upload", files=files, data=payload)

        assert response.status_code == 400
        assert response.json() == {
            "detail": "Invalid file type, only CSV files are accepted."
        }


def test_upload_transaction(client: TestClient):
    file_content = (
        "10.10.2023;10.10.2023;VISA FAKE SHOP;Lastschrift;FAKE;100;EUR;-13,00;EUR\n"
    )
    with patch("builtins.open", mock_open(read_data=file_content)):
        files = {"file": ("fake_path.csv", open("fake_path.csv", "r"), "text/csv")}
        payload = {"table_name": "sources.transactions"}
        response = client.post("/upload", files=files, data=payload)

        assert response.status_code == 200, response.text
        assert (
            response.json()["message"]
            == "Successfully added 1 new sources.transactions"
        )
