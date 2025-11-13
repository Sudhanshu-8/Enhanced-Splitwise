from datetime import datetime
from typing import Literal

from pydantic import BaseModel


class SettlementResponse(BaseModel):
    id: str
    from_user: str
    to_user: str
    amount: float
    status: Literal["pending", "completed", "cancelled"] = "pending"
    payment_link: str | None = None
    created_at: datetime
    updated_at: datetime


