from datetime import datetime, timezone
from typing import List
from uuid import uuid4

from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo import ReturnDocument
from pymongo.collection import Collection

from ..schemas import GroupCreate, GroupResponse, GroupUpdate


class GroupService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self._collection: Collection = db["groups"]

    async def create_group(self, creator_id: str, data: GroupCreate) -> GroupResponse:
        now = datetime.now(timezone.utc)
        members = list(set([creator_id] + data.members))
        doc = {
            "_id": str(uuid4()),
            "name": data.name,
            "description": data.description,
            "members": members,
            "total_balance": 0.0,
            "created_at": now,
            "updated_at": now,
        }
        await self._collection.insert_one(doc)
        return self._map(doc)

    async def list_groups(self, user_id: str) -> List[GroupResponse]:
        cursor = self._collection.find({"members": user_id})
        groups = []
        async for doc in cursor:
            doc["_id"] = str(doc["_id"])
            groups.append(self._map(doc))
        return groups

    async def get_group(self, group_id: str, user_id: str) -> GroupResponse:
        doc = await self._collection.find_one({"_id": group_id, "members": user_id})
        if not doc:
            raise HTTPException(status_code=404, detail="Group not found")
        return self._map(doc)

    async def update_group(
        self, group_id: str, user_id: str, updates: GroupUpdate
    ) -> GroupResponse:
        update_doc = {
            k: v for k, v in updates.dict(exclude_unset=True).items() if v is not None
        }
        if "members" in update_doc:
            update_doc["members"] = list(set(update_doc["members"]))
        update_doc["updated_at"] = datetime.now(timezone.utc)
        result = await self._collection.find_one_and_update(
            {"_id": group_id, "members": user_id},
            {"$set": update_doc},
            return_document=ReturnDocument.AFTER,
        )
        if not result:
            raise HTTPException(status_code=404, detail="Group not found")
        return self._map(result)

    async def delete_group(self, group_id: str, user_id: str) -> None:
        result = await self._collection.delete_one(
            {"_id": group_id, "members": user_id}
        )
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Group not found")

    def _map(self, doc: dict) -> GroupResponse:
        return GroupResponse(
            id=str(doc["_id"]),
            name=doc["name"],
            description=doc.get("description"),
            members=doc["members"],
            total_balance=doc.get("total_balance", 0.0),
            created_at=doc["created_at"],
            updated_at=doc["updated_at"],
        )

