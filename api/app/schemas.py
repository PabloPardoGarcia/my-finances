import datetime
from typing import Optional

from pydantic import BaseModel


class TransactionBase(BaseModel):
    booking: str
    value_date: str
    client_recipient: str
    booking_text: str
    purpose: str
    balance: str
    balance_currency: str
    amount: str
    amount_currency: str


class TransactionRead(TransactionBase):
    id: int
    inserted_at: datetime.datetime

    class ConfigDict:
        from_attributes = True


class TransactionWrite(TransactionBase):
    id: Optional[int]
    inserted_at: Optional[datetime.datetime]

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
