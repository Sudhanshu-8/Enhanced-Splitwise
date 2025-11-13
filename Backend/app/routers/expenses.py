from typing import Annotated, List

from fastapi import APIRouter, Depends, Query, status

from ..dependencies import get_current_user, get_db
from ..schemas import ExpenseCreate, ExpenseResponse, ExpenseUpdate, UserPublic
from ..services.expense_service import ExpenseService

router = APIRouter()


def get_expense_service(db=Depends(get_db)) -> ExpenseService:
    return ExpenseService(db)


@router.post("/", response_model=ExpenseResponse, status_code=status.HTTP_201_CREATED)
async def create_expense(
    payload: ExpenseCreate,
    _: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[ExpenseService, Depends(get_expense_service)],
) -> ExpenseResponse:
    return await service.create_expense(payload)


@router.get("/", response_model=List[ExpenseResponse])
async def list_expenses(
    group_id: Annotated[str, Query(min_length=1)],
    _: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[ExpenseService, Depends(get_expense_service)],
) -> List[ExpenseResponse]:
    return await service.list_expenses(group_id)


@router.get("/{expense_id}", response_model=ExpenseResponse)
async def read_expense(
    expense_id: str,
    _: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[ExpenseService, Depends(get_expense_service)],
) -> ExpenseResponse:
    return await service.get_expense(expense_id)


@router.patch("/{expense_id}", response_model=ExpenseResponse)
async def update_expense(
    expense_id: str,
    updates: ExpenseUpdate,
    _: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[ExpenseService, Depends(get_expense_service)],
) -> ExpenseResponse:
    return await service.update_expense(expense_id, updates)


@router.delete("/{expense_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_expense(
    expense_id: str,
    _: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[ExpenseService, Depends(get_expense_service)],
) -> None:
    await service.delete_expense(expense_id)


