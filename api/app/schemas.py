import datetime
from typing import Optional

from pydantic import BaseModel


class TransactionSource(BaseModel):
    booking: str
    value_date: str
    client_recipient: str
    booking_text: str
    purpose: str
    balance: str
    balance_currency: str
    amount: str
    amount_currency: str


class TransactionSourceWrite(TransactionSource):
    id: Optional[int]
    inserted_at: Optional[datetime.datetime]

    class ConfigDict:
        from_attributes = True


class TransactionMart(BaseModel):
    transaction_id: int
    booking_date: datetime.datetime
    value_date: datetime.datetime
    client_recipient: str
    booking_text: str
    purpose: str
    balance: float
    balance_currency: str
    amount: float
    amount_currency: str
    category_name: str | None
    category_created_at: datetime.datetime | None
    category_updated_at: datetime.datetime | None
    inserted_at: datetime.datetime

    class ConfigDict:
        from_attributes = True


class CategoryBase(BaseModel):
    name: str


class Category(CategoryBase):
    id: int
    created_at: datetime.datetime

    class ConfigDict:
        from_attributes = True


class TransactionCategoryBase(BaseModel):
    transaction_id: int
    category_id: int


class TransactionCategory(TransactionCategoryBase):
    id: int
    created_at: datetime.datetime
    updated_at: datetime.datetime

    class ConfigDict:
        from_attributes = True
