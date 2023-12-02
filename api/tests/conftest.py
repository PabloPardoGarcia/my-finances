from typing import Generator

from app.main import app

import pytest
from fastapi.testclient import TestClient


@pytest.fixture(scope="module")
def client() -> Generator:
    with TestClient(app) as c:
        yield c
