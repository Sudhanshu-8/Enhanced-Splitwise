from typing import Annotated

from fastapi import APIRouter, Depends

from ..services.payment_service import PaymentService

router = APIRouter()


def get_payment_service() -> PaymentService:
    return PaymentService()


@router.post("/intent")
async def create_payment_intent(
    service: Annotated[PaymentService, Depends(get_payment_service)],
    amount: float,
    currency: str = "USD",
    description: str | None = None,
) -> dict:
    payment_link = await service.create_payment_link(amount, currency, description)
    return {"payment_link": payment_link}


