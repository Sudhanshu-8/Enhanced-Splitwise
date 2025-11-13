from fastapi import APIRouter

from . import auth, expenses, groups, ocr, payments, settlements, users

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["Auth"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(groups.router, prefix="/groups", tags=["Groups"])
api_router.include_router(expenses.router, prefix="/expenses", tags=["Expenses"])
api_router.include_router(settlements.router, prefix="/settlements", tags=["Settlements"])
api_router.include_router(ocr.router, prefix="/ocr", tags=["OCR"])
api_router.include_router(payments.router, prefix="/payments", tags=["Payments"])


