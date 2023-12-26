from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, func, Float

from .database import Base


class TransactionSource(Base):
    __tablename__ = "transactions"
    __table_args__ = {"schema": "sources"}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    booking = Column(String)
    value_date = Column(String)
    client_recipient = Column(String)
    booking_text = Column(String)
    purpose = Column(String)
    balance = Column(String)
    balance_currency = Column(String)
    amount = Column(String)
    amount_currency = Column(String)
    inserted_at = Column(DateTime, nullable=True, default=func.now())


class TransactionMart(Base):
    __tablename__ = "transactions"
    __table_args__ = {"schema": "dbt_finances"}

    transaction_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    booking_date = Column(DateTime)
    value_date = Column(String)
    client_recipient = Column(String)
    booking_text = Column(String)
    purpose = Column(String)
    balance = Column(Float)
    balance_currency = Column(String)
    amount = Column(Float)
    amount_currency = Column(String)
    category_name = Column(String, nullable=True)
    category_created_at = Column(DateTime, nullable=True)
    category_updated_at = Column(DateTime, nullable=True)
    inserted_at = Column(DateTime, nullable=True, default=func.now())


class Category(Base):
    __tablename__ = "categories"
    __table_args__ = {"schema": "sources"}

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    created_at = Column(DateTime, nullable=True, default=func.now())


class TransactionCategory(Base):
    __tablename__ = "transaction_categories"
    __table_args__ = {"schema": "sources"}

    id = Column(Integer, primary_key=True, index=True)
    transaction_id = Column(Integer, ForeignKey("transactions.id"))
    category_id = Column(Integer, ForeignKey("categories.id"))
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
