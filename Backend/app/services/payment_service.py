from __future__ import annotations

import secrets
from typing import Literal

import httpx
from fastapi import HTTPException, status

from ..config import get_settings


class PaymentService:
    def __init__(self) -> None:
        self._settings = get_settings()

    async def create_payment_link(
        self,
        amount: float,
        currency: str = "USD",
        description: str | None = None,
    ) -> str:
        if self._settings.payment_provider_base_url and self._settings.payment_provider_api_key:
            return await self._create_external_link(amount, currency, description)
        return self._create_mock_link(amount, currency, description)

    async def _create_external_link(
        self, amount: float, currency: str, description: str | None
    ) -> str:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self._settings.payment_provider_base_url}/payment-links",
                headers={"Authorization": f"Bearer {self._settings.payment_provider_api_key}"},
                json={
                    "amount": amount,
                    "currency": currency,
                    "description": description,
                },
                timeout=10,
            )
            if response.status_code >= 400:
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="Payment provider request failed",
                )
            data = response.json()
            return data.get("url") or data.get("payment_url")

    def _create_mock_link(self, amount: float, currency: str, description: str | None) -> str:
        token = secrets.token_urlsafe(16)
        return f"https://pay.splitit.local/checkout/{token}?amount={amount}&currency={currency}"


