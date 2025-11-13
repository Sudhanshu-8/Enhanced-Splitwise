from typing import Annotated

from fastapi import APIRouter, Depends, status

from ..dependencies import get_current_user, get_user_service
from ..schemas import UserPublic, UserUpdate
from ..services.user_service import UserService

router = APIRouter()


@router.get("/me", response_model=UserPublic)
async def read_current_user(
    current_user: Annotated[UserPublic, Depends(get_current_user)]
) -> UserPublic:
    return current_user


@router.patch("/me", response_model=UserPublic)
async def update_current_user(
    updates: UserUpdate,
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> UserPublic:
    return await user_service.update_user(current_user.id, updates)


