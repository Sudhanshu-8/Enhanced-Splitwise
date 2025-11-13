from functools import lru_cache
from typing import List

from pydantic import AnyUrl, BaseSettings, Field


class Settings(BaseSettings):
    app_name: str = Field(default="Enhanced Splitwise API")
    api_v1_prefix: str = Field(default="/api/v1")

    mongodb_uri: AnyUrl = Field(
        default="mongodb://localhost:27017", alias="MONGODB_URI"
    )
    mongodb_db: str = Field(default="splitbill", alias="MONGODB_DB")

    jwt_secret_key: str = Field(default="super-secret-key", alias="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(
        default=60 * 24, alias="ACCESS_TOKEN_EXPIRE_MINUTES"
    )

    cors_origins: List[AnyUrl] = Field(default_factory=list, alias="CORS_ORIGINS")

    payment_provider_base_url: AnyUrl | None = Field(
        default=None, alias="PAYMENT_PROVIDER_BASE_URL"
    )
    payment_provider_api_key: str | None = Field(
        default=None, alias="PAYMENT_PROVIDER_API_KEY"
    )
    ocr_tesseract_cmd: str | None = Field(default=None, alias="OCR_TESSERACT_CMD")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()


