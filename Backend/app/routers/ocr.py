from typing import Annotated

from fastapi import APIRouter, Depends, UploadFile

from ..dependencies import get_current_user
from ..schemas import UserPublic
from ..services.ocr_service import OCRService

router = APIRouter()


def get_ocr_service() -> OCRService:
    return OCRService()


@router.post("/parse")
async def parse_receipt(
    file: UploadFile,
    _: Annotated[UserPublic, Depends(get_current_user)],
    service: Annotated[OCRService, Depends(get_ocr_service)],
) -> dict:
    return await service.parse_receipt(file)


