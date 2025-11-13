import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .database import close_client, get_database
from .routers import api_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name)

    # CORS: Allow all origins for mobile apps (Flutter doesn't have a specific origin)
    # In production, you might want to restrict this
    if settings.cors_origins:
        origins = [str(origin) for origin in settings.cors_origins]
        app.add_middleware(
            CORSMiddleware,
            allow_origins=origins,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
    else:
        # Allow all origins (for mobile apps)
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=False,  # Can't use credentials with wildcard
            allow_methods=["*"],
            allow_headers=["*"],
        )

    app.include_router(api_router, prefix=settings.api_v1_prefix)

    @app.on_event("startup")
    async def startup_event() -> None:
        """Log startup information and test database connection."""
        logger.info("=" * 50)
        logger.info(f"Starting {settings.app_name}")
        logger.info(f"MongoDB URI: {settings.mongodb_uri}")
        logger.info(f"Database: {settings.mongodb_db}")
        logger.info(f"API prefix: {settings.api_v1_prefix}")
        
        # Test database connection
        try:
            db = get_database()
            # Ping the database
            await db.client.admin.command("ping")
            logger.info("✓ MongoDB connection successful")
        except Exception as e:
            logger.error(f"✗ MongoDB connection failed: {e}")
            logger.warning("The app will continue but database operations may fail")
        
        logger.info("=" * 50)

    @app.get("/healthz", tags=["Health"])
    async def health_check() -> dict:
        """Health check endpoint."""
        try:
            db = get_database()
            await db.client.admin.command("ping")
            return {"status": "ok", "database": "connected"}
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return {"status": "error", "database": "disconnected", "error": str(e)}

    @app.on_event("shutdown")
    async def shutdown_client() -> None:
        logger.info("Shutting down...")
        await close_client()

    return app


app = create_app()


