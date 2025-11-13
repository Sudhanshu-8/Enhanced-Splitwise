from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class GroupBase(BaseModel):
    name: str
    description: Optional[str] = None


class GroupCreate(GroupBase):
    members: List[str]


class GroupUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    members: Optional[List[str]] = None


class GroupResponse(GroupBase):
    id: str
    members: List[str]
    total_balance: float = 0.0
    created_at: datetime
    updated_at: datetime


