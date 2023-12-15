import codecs
import csv
from typing import Annotated

from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from . import crud, dbt, models, schemas
from .database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="My Finances Uploader App", version="0.0.0", root_path="/api")


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
async def root():
    return {"message": "Hello world"}


@app.post("/upload")
def upload(
    file: Annotated[UploadFile, File()],
    table_name: Annotated[str, Form()],
    update_dbt: Annotated[bool, Form()] = True,
    db: Session = Depends(get_db),
):
    if file.content_type != "text/csv":
        raise HTTPException(
            status_code=400, detail="Invalid file type, only CSV files are accepted."
        )

    if table_name == "sources.transactions":
        header = [
            "booking",
            "value_date",
            "client_recipient",
            "booking_text",
            "purpose",
            "balance",
            "balance_currency",
            "amount",
            "amount_currency",
        ]
        schema = schemas.TransactionBase
        crud_create = crud.create_transaction
    elif table_name == "sources.categories":
        header = ["name"]
        schema = schemas.CategoryBase
        crud_create = crud.create_category
    else:
        raise HTTPException(
            status_code=400,
            detail="Invalid table name, only transactions or " "categories are valid.",
        )
    try:
        counts = 0
        reader = csv.DictReader(
            codecs.iterdecode(file.file, "utf-8"), delimiter=";", fieldnames=header
        )
        for row in reader:
            crud_create(db=db, transaction=schema.model_validate(row))
            counts += 1

    except Exception as e:
        return {"message": f"There was an error uploading the file. {e}"}
    finally:
        file.file.close()

    if update_dbt:
        try:
            print("running dbt")
            dbt.run()
            print("dbt update triggered")
        except Exception as e:
            return {"message": f"There was an error updating dbt models: {e}"}

    return {"message": f"Successfully added {counts} new {table_name}"}


@app.get("/transactions", response_model=list[schemas.TransactionRead])
def read_transactions(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    transactions = crud.get_transactions(db=db, skip=skip, limit=limit)
    return transactions


@app.get("/categories", response_model=list[schemas.Category])
def read_categories(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    categories = crud.get_categories(db=db, skip=skip, limit=limit)
    return categories
