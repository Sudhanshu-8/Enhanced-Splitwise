#!/usr/bin/env python3
"""
Quick start script for the backend server.
This script helps verify the setup before starting uvicorn.
"""
import asyncio
import sys
from motor.motor_asyncio import AsyncIOMotorClient

from app.config import get_settings
from app.database import get_client


async def check_mongodb():
    """Check if MongoDB is accessible."""
    settings = get_settings()
    print(f"Checking MongoDB connection to: {settings.mongodb_uri}")
    try:
        client = get_client()
        # Ping the database
        await client.admin.command("ping")
        print("✓ MongoDB connection successful!")
        return True
    except Exception as e:
        print(f"✗ MongoDB connection failed: {e}")
        print("\nPlease make sure:")
        print("1. MongoDB is installed and running")
        print("2. The MONGODB_URI in your .env file is correct")
        print("3. MongoDB is accessible at the specified address")
        return False


def main():
    """Main entry point."""
    print("=" * 50)
    print("Enhanced Splitwise Backend - Setup Check")
    print("=" * 50)
    
    settings = get_settings()
    print(f"\nConfiguration:")
    print(f"  MongoDB URI: {settings.mongodb_uri}")
    print(f"  Database: {settings.mongodb_db}")
    print(f"  API Prefix: {settings.api_v1_prefix}")
    print(f"  JWT Secret: {'*' * 20} (hidden)")
    
    # Check MongoDB
    print("\nChecking MongoDB...")
    result = asyncio.run(check_mongodb())
    
    if not result:
        print("\n⚠️  Warning: MongoDB connection failed. The server will start but may not work properly.")
        response = input("\nContinue anyway? (y/n): ")
        if response.lower() != 'y':
            print("Exiting...")
            sys.exit(1)
    
    print("\n" + "=" * 50)
    print("Starting server with uvicorn...")
    print("=" * 50)
    print("\nServer will be available at: http://localhost:8000")
    print("API docs will be at: http://localhost:8000/docs")
    print("\nPress Ctrl+C to stop the server\n")
    
    # Start uvicorn
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)


if __name__ == "__main__":
    main()

