from typing import Annotated, List

from fastapi import APIRouter, Depends, status

from ..dependencies import get_current_user, get_db
from ..schemas import GroupCreate, GroupResponse, GroupUpdate, UserPublic
from ..services.group_service import GroupService

router = APIRouter()


def get_group_service(db=Depends(get_db)) -> GroupService:
    return GroupService(db)


@router.post("/", response_model=GroupResponse, status_code=status.HTTP_201_CREATED)
async def create_group(
    payload: GroupCreate,
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[GroupService, Depends(get_group_service)],
) -> GroupResponse:
    return await service.create_group(current_user.id, payload)


@router.get("/", response_model=List[GroupResponse])
async def list_groups(
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[GroupService, Depends(get_group_service)],
) -> List[GroupResponse]:
    return await service.list_groups(current_user.id)


@router.get("/{group_id}", response_model=GroupResponse)
async def read_group(
    group_id: str,
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[GroupService, Depends(get_group_service)],
) -> GroupResponse:
    return await service.get_group(group_id, current_user.id)


@router.patch("/{group_id}", response_model=GroupResponse)
async def update_group(
    group_id: str,
    updates: GroupUpdate,
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[GroupService, Depends(get_group_service)],
) -> GroupResponse:
    return await service.update_group(group_id, current_user.id, updates)


@router.delete("/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_group(
    group_id: str,
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[GroupService, Depends(get_group_service)],
) -> None:
    await service.delete_group(group_id, current_user.id)


