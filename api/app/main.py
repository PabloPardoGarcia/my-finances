from .db import copy_file, get_table_size
from .models import Database

import os
from typing import Annotated

from fastapi import FastAPI, UploadFile, HTTPException, Form, File


database = Database(
    host=os.getenv("POSTGRES_HOST"),
    port=os.getenv("POSTGRES_PORT", default=5432),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD"),
    dbname=os.getenv("POSTGRES_DB")
)

app = FastAPI(
    title="My Finances Uploader App",
    version="0.0.0",
    root_path="/api"
)


@app.get("/")
async def root():
    return {"message": "Hello world"}


@app.post("/upload")
def upload_csv_to_table(file: Annotated[UploadFile, File()], table_name: Annotated[str, Form()]):
    if file.content_type != "text/csv":
        raise HTTPException(
            status_code=400,
            detail="Invalid file type, only CSV files are accepted."
        )

    try:
        table_count_before = get_table_size(
            table_name=table_name,
            connection_str=database.get_connection_str()
        )
        copy_file(
            file=file.file,
            connection_str=database.get_connection_str(),
            table_name=table_name,
            table_cols=[
                "booking", "value_date", "client_recipient",
                "booking_text", "purpose", "balance",
                "balance_currency", "amount", "amount_currency"
            ],
            options=["HEADER", "CSV", "DELIMITER ';'"]
        )
        table_count_after = get_table_size(
            table_name=table_name,
            connection_str=database.get_connection_str()
        )
    except Exception as e:
        return {"message": f"There was an error uploading the file. {e}"}
    finally:
        file.file.close()

    return {
        "message": f"Successfully added {table_count_after - table_count_before} new records to table {table_name}"
    }
