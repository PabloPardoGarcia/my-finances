from sqlalchemy.orm import Session

from . import models, schemas


def get_transactions(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Transaction).offset(skip).limit(limit).all()


def create_transaction(db: Session, transaction: schemas.TransactionBase):
    db_transaction = models.Transaction(**transaction.model_dump())
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    return db_transaction


def create_category(db: Session, category: schemas.CategoryBase):
    db_category = models.Category(**category.model_dump())
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category


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
