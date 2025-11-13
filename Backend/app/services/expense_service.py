from __future__ import annotations

from datetime import datetime, timezone
from typing import Dict, List
from uuid import uuid4

from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo import ReturnDocument
from pymongo.collection import Collection

from ..schemas import ExpenseCreate, ExpenseResponse, ExpenseUpdate


class ExpenseService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self._collection: Collection = db["expenses"]

    async def create_expense(self, data: ExpenseCreate) -> ExpenseResponse:
        balances = self._calculate_balances(data)
        now = datetime.now(timezone.utc)
        doc = {
            "_id": str(uuid4()),
            "group_id": data.group_id,
            "title": data.title,
            "amount": data.amount,
            "paid_by": data.paid_by,
            "category": data.category,
            "notes": data.notes,
            "receipt_url": data.receipt_url,
            "split": [item.dict() for item in data.split],
            "occurred_at": data.occurred_at,
            "balances": balances,
            "created_at": now,
            "updated_at": now,
        }
        await self._collection.insert_one(doc)
        return self._map(doc)

    async def list_expenses(self, group_id: str) -> List[ExpenseResponse]:
        cursor = self._collection.find({"group_id": group_id}).sort("occurred_at", -1)
        expenses: List[ExpenseResponse] = []
        async for doc in cursor:
            expenses.append(self._map(doc))
        return expenses

    async def get_expense(self, expense_id: str) -> ExpenseResponse:
        doc = await self._collection.find_one({"_id": expense_id})
        if not doc:
            raise HTTPException(status_code=404, detail="Expense not found")
        return self._map(doc)

    async def update_expense(
        self, expense_id: str, updates: ExpenseUpdate
    ) -> ExpenseResponse:
        update_doc = {
            k: v for k, v in updates.dict(exclude_unset=True).items() if v is not None
        }
        if "split" in update_doc or "amount" in update_doc:
            expense = await self._collection.find_one({"_id": expense_id})
            if not expense:
                raise HTTPException(status_code=404, detail="Expense not found")
            merged = {**expense, **update_doc}
            merged_split = merged.get("split", [])
            update_doc["balances"] = self._calculate_balances_from_doc(
                merged["amount"], merged["paid_by"], merged_split
            )
        update_doc["updated_at"] = datetime.now(timezone.utc)
        result = await self._collection.find_one_and_update(
            {"_id": expense_id},
            {"$set": update_doc},
            return_document=ReturnDocument.AFTER,
        )
        if not result:
            raise HTTPException(status_code=404, detail="Expense not found")
        return self._map(result)

    async def delete_expense(self, expense_id: str) -> None:
        await self._collection.delete_one({"_id": expense_id})

    def _calculate_balances(self, data: ExpenseCreate) -> Dict[str, float]:
        return self._calculate_balances_from_doc(
            data.amount, data.paid_by, [item.dict() for item in data.split]
        )

    def _calculate_balances_from_doc(
        self, amount: float, paid_by: str, split: List[dict]
    ) -> Dict[str, float]:
        balances: Dict[str, float] = {}
        total_shares = sum(item["share"] for item in split)
        if total_shares == 0:
            raise HTTPException(status_code=400, detail="Split shares must sum to more than zero")
        share_amount = amount / total_shares
        for item in split:
            participant = item["participant_id"]
            owed = share_amount * item["share"]
            balances[participant] = round(balances.get(participant, 0.0) - owed, 2)
        balances[paid_by] = round(balances.get(paid_by, 0.0) + amount, 2)
        return balances

    def _map(self, doc: dict) -> ExpenseResponse:
        return ExpenseResponse(
            id=str(doc["_id"]),
            group_id=doc["group_id"],
            title=doc["title"],
            amount=doc["amount"],
            paid_by=doc["paid_by"],
            category=doc.get("category"),
            notes=doc.get("notes"),
            receipt_url=doc.get("receipt_url"),
            split=doc["split"],
            occurred_at=doc["occurred_at"],
            balances=doc.get("balances", {}),
            created_at=doc["created_at"],
            updated_at=doc["updated_at"],
        )

