from typing import Annotated, List

from fastapi import APIRouter, Depends, status

from ..dependencies import get_current_user, get_db
from ..schemas import SettlementResponse, UserPublic
from ..services.payment_service import PaymentService
from ..services.settlement_service import SettlementService

router = APIRouter()


def get_settlement_service(db=Depends(get_db)) -> SettlementService:
    return SettlementService(db)


def get_payment_service() -> PaymentService:
    return PaymentService()


@router.get("/", response_model=List[SettlementResponse])
async def list_settlements(
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[SettlementService, Depends(get_settlement_service)],
) -> List[SettlementResponse]:
    return await service.list_user_settlements(current_user.id)


@router.post("/", response_model=SettlementResponse, status_code=status.HTTP_201_CREATED)
async def create_settlement(
    to_user: str,
    amount: float,
    current_user: Annotated[UserPublic, Depends(get_current_user)],
    settlement_service: Annotated[SettlementService, Depends(get_settlement_service)],
    payment_service: Annotated[PaymentService, Depends(get_payment_service)],
) -> SettlementResponse:
    payment_link = await payment_service.create_payment_link(
        amount, currency="USD", description=f"Settlement from {current_user.id}"
    )
    return await settlement_service.create_settlement(
        current_user.id, to_user, amount, payment_link
    )


