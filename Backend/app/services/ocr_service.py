from __future__ import annotations

import io
import re
from typing import Dict, List

from fastapi import HTTPException, UploadFile, status
from PIL import Image

from ..config import get_settings

try:
    import pytesseract
except ImportError:  # pragma: no cover - optional dependency
    pytesseract = None  # type: ignore


class OCRService:
    def __init__(self) -> None:
        self._settings = get_settings()
        if self._settings.ocr_tesseract_cmd and pytesseract:
            pytesseract.pytesseract.tesseract_cmd = self._settings.ocr_tesseract_cmd

    async def parse_receipt(self, file: UploadFile) -> Dict[str, str | float | List[Dict[str, str]]]:
        if not pytesseract:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="OCR engine not installed. Install pytesseract and Tesseract OCR.",
            )
        image_bytes = await file.read()
        try:
            image = Image.open(io.BytesIO(image_bytes))
            text = pytesseract.image_to_string(image)
        except Exception as exc:  # pragma: no cover
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to process image",
            ) from exc

        return self._parse_text(text)

    def _parse_text(self, text: str) -> Dict[str, str | float | List[Dict[str, str]]]:
        merchant = self._extract_merchant(text)
        date = self._extract_date(text)
        total = self._extract_total(text)
        line_items = self._extract_line_items(text)
        return {
            "merchant": merchant,
            "date": date,
            "total": total,
            "currency": "USD",
            "items": line_items,
            "raw_text": text,
        }

    def _extract_merchant(self, text: str) -> str:
        first_line = text.strip().splitlines()[0]
        return first_line[:120]

    def _extract_date(self, text: str) -> str | None:
        match = re.search(r"(\d{2}[/-]\d{2}[/-]\d{2,4})", text)
        return match.group(1) if match else None

    def _extract_total(self, text: str) -> float | None:
        matches = re.findall(r"total\s*[:\-]?\s*\$?(\d+[\.\d{2}]*)", text, re.IGNORECASE)
        if matches:
            return float(matches[-1].replace(",", ""))
        numbers = re.findall(r"\$?(\d+\.\d{2})", text)
        return float(numbers[-1]) if numbers else None

    def _extract_line_items(self, text: str) -> List[Dict[str, str]]:
        items: List[Dict[str, str]] = []
        for line in text.splitlines():
            if re.search(r"\b\d+\.\d{2}\b", line):
                parts = line.rsplit(" ", 1)
                if len(parts) == 2:
                    items.append({"description": parts[0].strip(), "amount": parts[1].strip()})
        return items


