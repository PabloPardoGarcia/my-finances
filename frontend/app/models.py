import datetime

from pydantic import BaseModel


class Transaction(BaseModel):
    id: int
    booking: str
    value_date: str
    client_recipient: str
    booking_text: str
    purpose: str
    balance: str
    balance_currency: str
    amount: str
    amount_currency: str
    inserted_at: datetime.datetime


class APIResponse(BaseModel):
    items: list[Transaction]
    total: int
    page: int
    size: int
    pages: int
