import pytest
from unittest.mock import mock_open, patch
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
    file_content = 'test_file.docx'
    with patch("builtins.open", mock_open(read_data=file_content)):
        files = {"file": ("fake_path.json", open("fake_path.json", "r"), "application/json")}
        payload = {"table_name": "fake_table"}
        response = client.post("/upload", files=files, data=payload)

        assert response.status_code == 400
        assert response.json() == {"detail": "Invalid file type, only CSV files are accepted."}
