from datetime import timedelta
from typing import Annotated

from fastapi import Depends, Header, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from motor.motor_asyncio import AsyncIOMotorDatabase

from .database import get_database
from .schemas import TokenPayload, UserPublic
from .security import decode_token
from .services.user_service import UserService

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_db() -> AsyncIOMotorDatabase:
    return get_database()


async def get_user_service(db: Annotated[AsyncIOMotorDatabase, Depends(get_db)]) -> UserService:
    return UserService(db)


async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> UserPublic:
    payload = TokenPayload(**decode_token(token))
    user = await user_service.get_user_by_id(payload.sub)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User no longer exists",
        )
    return user


