from datetime import datetime, timezone
from typing import Optional

from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase
from pymongo import ReturnDocument
from pymongo.collection import Collection

from ..schemas import UserCreate, UserPublic, UserUpdate
from ..security import hash_password, verify_password


class UserService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self._collection: Collection = db["users"]

    async def get_user_by_email(self, email: str) -> Optional[UserPublic]:
        doc = await self._collection.find_one({"email": email})
        return self._map_to_user_public(doc) if doc else None

    async def get_user_by_id(self, user_id: str) -> Optional[UserPublic]:
        doc = await self._collection.find_one({"_id": user_id})
        return self._map_to_user_public(doc) if doc else None

    async def register_user(self, user: UserCreate) -> UserPublic:
        existing = await self._collection.find_one({"email": user.email})
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

        now = datetime.now(timezone.utc)
        doc = {
            "_id": str(user.email).lower(),
            "email": user.email,
            "full_name": user.full_name,
            "avatar_url": user.avatar_url,
            "hashed_password": hash_password(user.password),
            "created_at": now,
            "updated_at": now,
        }
        await self._collection.insert_one(doc)
        return self._map_to_user_public(doc)

    async def authenticate(self, email: str, password: str) -> UserPublic:
        doc = await self._collection.find_one({"email": email})
        if not doc:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
            )
        if not verify_password(password, doc["hashed_password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
            )
        return self._map_to_user_public(doc)

    async def update_user(self, user_id: str, updates: UserUpdate) -> UserPublic:
        update_doc = {k: v for k, v in updates.dict(exclude_unset=True).items()}
        if not update_doc:
            user = await self._collection.find_one({"_id": user_id})
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
            return self._map_to_user_public(user)

        update_doc["updated_at"] = datetime.now(timezone.utc)
        result = await self._collection.find_one_and_update(
            {"_id": user_id},
            {"$set": update_doc},
            return_document=ReturnDocument.AFTER,
        )
        if not result:
            raise HTTPException(status_code=404, detail="User not found")
        return self._map_to_user_public(result)

    def _map_to_user_public(self, doc: dict) -> UserPublic:
        return UserPublic(
            id=doc["_id"],
            email=doc["email"],
            full_name=doc.get("full_name"),
            avatar_url=doc.get("avatar_url"),
            created_at=doc["created_at"],
            updated_at=doc["updated_at"],
        )

