# Enhanced Splitwise API

FastAPI backend that powers the Enhanced Splitwise application. It provides endpoints for user management, groups, expenses, OCR based receipt parsing, and payment link generation.

## Features

- JWT based authentication
- Group and expense management with MongoDB
- OCR parsing using Tesseract (optional mock fallback)
- Payment link creation with optional provider integration
- Settlement tracking

## Getting Started

### Prerequisites

- Python 3.11+
- MongoDB (local or hosted)
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) (optional but recommended)

### Installation

```bash
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

Create a `.env` file in the `Backend` directory (or configure environment variables):

```env
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017
MONGODB_DB=splitbill

# JWT Configuration
JWT_SECRET_KEY=change-this-to-a-random-secret-key-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# CORS Origins (optional - leave empty to allow all origins for mobile apps)
# For web apps, you can specify: CORS_ORIGINS=["http://localhost:3000","http://127.0.0.1:5173"]
# For mobile apps (Flutter), leave this empty or don't set it

# Payment Provider (optional)
# PAYMENT_PROVIDER_BASE_URL=https://api.payment-provider.com
# PAYMENT_PROVIDER_API_KEY=your-api-key

# OCR Configuration (optional)
# Windows: OCR_TESSERACT_CMD=C:\\Program Files\\Tesseract-OCR\\tesseract.exe
# Linux/Mac: OCR_TESSERACT_CMD=/usr/bin/tesseract
```

**Note**: MongoDB is already configured and used in this backend. Make sure MongoDB is running before starting the server.

### Running the server

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`. Swagger docs are available at `/docs`.

## Testing OCR

Use the `/api/v1/ocr/parse` endpoint with a multipart file upload. If Tesseract is not installed, the endpoint returns a 503 error with installation instructions.

## Folder Structure

- `app/config.py` – global settings
- `app/database.py` – Mongo connection helpers
- `app/routers` – FastAPI routers
- `app/services` – business logic
- `app/schemas` – Pydantic models

## Running Tests

Test stubs can be added under `tests/` (not included by default). Install `pytest` and add your test cases.


