from fastapi_pagination.ext.sqlalchemy import paginate
from sqlalchemy import select
from sqlalchemy.orm import Session

from . import models, schemas


def get_transactions(db: Session):
    return paginate(
        db, select(models.Transaction).order_by(models.Transaction.inserted_at)
    )


def create_transaction(db: Session, transaction: schemas.TransactionBase):
    transaction_dump = transaction.model_dump()
    db_transaction = models.Transaction(**transaction_dump)
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    print(f"Created transaction {transaction_dump}")
    return db_transaction


def create_category(db: Session, category: schemas.CategoryBase):
    db_category = models.Category(**category.model_dump())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category


def get_categories(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Category).offset(skip).limit(limit).all()


def create_transaction_category(
    db: Session, transaction_category: schemas.TransactionCategoryBase
):
    db_transaction_category = models.TransactionCategory(
        **transaction_category.model_dump()
    )
    db.add(db_transaction_category)
    db.commit()
    db.refresh(db_transaction_category)
    return db_transaction_category
