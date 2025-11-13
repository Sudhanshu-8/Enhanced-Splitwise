from datetime import datetime
from typing import Dict, List, Optional

from pydantic import BaseModel, Field


class ExpenseItem(BaseModel):
    participant_id: str
    share: float = Field(ge=0)


class ExpenseBase(BaseModel):
    group_id: str
    title: str
    amount: float = Field(gt=0)
    paid_by: str
    category: Optional[str] = None
    notes: Optional[str] = None
    receipt_url: Optional[str] = None
    split: List[ExpenseItem]


class ExpenseCreate(ExpenseBase):
    occurred_at: datetime


class ExpenseUpdate(BaseModel):
    title: Optional[str] = None
    amount: Optional[float] = Field(default=None, gt=0)
    paid_by: Optional[str] = None
    category: Optional[str] = None
    notes: Optional[str] = None
    receipt_url: Optional[str] = None
    split: Optional[List[ExpenseItem]] = None
    occurred_at: Optional[datetime] = None


class ExpenseResponse(ExpenseBase):
    id: str
    occurred_at: datetime
    balances: Dict[str, float]
    created_at: datetime
    updated_at: datetime


