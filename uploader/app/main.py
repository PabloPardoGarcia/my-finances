from .db import copy_file, get_table_size
from .models import Database

import os
from pathlib import Path
from typing import Annotated

from fastapi import FastAPI, UploadFile, HTTPException, Request, Form, File
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

BASE_DIR = Path(__file__).resolve().parent

database = Database(
    host=os.getenv("POSTGRES_HOST"),
    port=os.getenv("POSTGRES_PORT", default=5432),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD"),
    dbname=os.getenv("POSTGRES_DB")
)
templates = Jinja2Templates(directory=str(Path(BASE_DIR, "templates")))
app = FastAPI(
    title="My Finances Uploader App",
    version="0.0.0"
)


@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse(
        name="index.html",
        context={"request": request}
    )


@app.get("/upload", response_class=HTMLResponse)
def upload(request: Request):
    return templates.TemplateResponse(
        name="upload.html",
        context={"request": request, "results": None}
    )


@app.post("/upload", response_class=HTMLResponse)
def upload_csv_to_table(request: Request, file: Annotated[UploadFile, File()], table_name: Annotated[str, Form()]):
    if file.content_type != "text/csv":
        raise HTTPException(
            status_code=400,
            detail="Invalid file type, only CSV files are accepted."
        )

    try:
        table_count_before = get_table_size(table_name=table_name, database=database)
        copy_file(
            file=file.file,
            database=database,
            table_name=table_name,
            options=["HEADER", "CSV", "DELIMITER ';'"]
        )
        table_count_after = get_table_size(table_name=table_name, database=database)
    except Exception as e:
        return {"message": f"There was an error uploading the file. {e}"}
    finally:
        file.file.close()

    return templates.TemplateResponse(
        name="upload.html",
        context={"request": request, "results": {
            "filename": file.filename,
            "table_count_before": table_count_before,
            "table_count_after": table_count_after
        }}
    )
