import datetime

from pydantic import BaseModel


class Transaction(BaseModel):
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


class APIResponse(BaseModel):
    items: list[Transaction]
    total: int
    page: int
    size: int
    pages: int
