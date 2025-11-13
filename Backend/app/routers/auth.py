import logging
from datetime import timedelta
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from ..config import get_settings
from ..dependencies import get_user_service
from ..schemas import Token, UserCreate, UserPublic
from ..security import create_access_token
from ..services.user_service import UserService

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED)
async def register_user(
    payload: UserCreate,
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> UserPublic:
    logger.info(f"Registration attempt for email: {payload.email}")
    try:
        user = await user_service.register_user(payload)
        logger.info(f"User registered successfully: {user.email}")
        return user
    except Exception as e:
        logger.error(f"Registration failed for {payload.email}: {e}")
        raise


@router.post("/login", response_model=Token)
async def login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> Token:
    logger.info(f"Login attempt for username: {form_data.username}")
    try:
        user = await user_service.authenticate(form_data.username, form_data.password)
        settings = get_settings()
        access_token = create_access_token(
            subject=user.id,
            expires_delta=timedelta(minutes=settings.access_token_expire_minutes),
        )
        logger.info(f"Login successful for user: {user.email}")
        return Token(access_token=access_token)
    except HTTPException as e:
        logger.warning(f"Login failed for {form_data.username}: {e.detail}")
        raise
    except Exception as e:
        logger.error(f"Login error for {form_data.username}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during login",
        )


