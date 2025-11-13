from datetime import datetime, timezone
from typing import List
from uuid import uuid4

from fastapi import HTTPException
from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo import ReturnDocument
from pymongo.collection import Collection

from ..schemas import SettlementResponse


class SettlementService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self._collection: Collection = db["settlements"]

    async def create_settlement(
        self, from_user: str, to_user: str, amount: float, payment_link: str | None
    ) -> SettlementResponse:
        now = datetime.now(timezone.utc)
        doc = {
            "_id": str(uuid4()),
            "from_user": from_user,
            "to_user": to_user,
            "amount": amount,
            "status": "pending",
            "payment_link": payment_link,
            "created_at": now,
            "updated_at": now,
        }
        await self._collection.insert_one(doc)
        return self._map(doc)

    async def list_user_settlements(self, user_id: str) -> List[SettlementResponse]:
        cursor = self._collection.find(
            {"$or": [{"from_user": user_id}, {"to_user": user_id}]}
        ).sort("created_at", -1)
        settlements: List[SettlementResponse] = []
        async for doc in cursor:
            settlements.append(self._map(doc))
        return settlements

    async def update_status(
        self, settlement_id: str, status: str
    ) -> SettlementResponse:
        doc = await self._collection.find_one_and_update(
            {"_id": settlement_id},
            {
                "$set": {
                    "status": status,
                    "updated_at": datetime.now(timezone.utc),
                }
            },
            return_document=ReturnDocument.AFTER,
        )
        if not doc:
            raise HTTPException(status_code=404, detail="Settlement not found")
        return self._map(doc)

    def _map(self, doc: dict) -> SettlementResponse:
        return SettlementResponse(
            id=str(doc["_id"]),
            from_user=doc["from_user"],
            to_user=doc["to_user"],
            amount=doc["amount"],
            status=doc["status"],
            payment_link=doc.get("payment_link"),
            created_at=doc["created_at"],
            updated_at=doc["updated_at"],
        )

