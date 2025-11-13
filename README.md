# Enhanced Splitwise 💰

AI-assisted expense manager that scans receipts, tracks shared expenses, and helps groups settle up faster. The project is built as a Flutter mobile app backed by a FastAPI service with OCR and payment integrations.

## Project Structure

```
.
├── Frontend/   # Flutter application
├── Backend/    # FastAPI service + MongoDB integrations
└── OCR/        # Sample OCR assets / experiments
```

## Highlights

- **Smart OCR pipeline** – Upload a bill image and extract totals, merchant name, and line items.
- **Expense automation** – Create groups, split expenses across participants, and keep balances.
- **Payment links** – Generate settlement payment links (mock mode by default, pluggable providers).
- **Modern mobile UI** – Flutter app with Riverpod, GoRouter, and FlexColorScheme for a polished experience.

## Getting Started

### Backend

1. `cd Backend`
2. `python -m venv .venv`
3. `.venv\Scripts\activate` (PowerShell: `.\.venv\Scripts\Activate.ps1`)
4. `pip install -r requirements.txt`
5. Copy `.env.example` (create one if missing) and update:

   ```env
   MONGODB_URI=mongodb://localhost:27017
   MONGODB_DB=splitbill
   JWT_SECRET_KEY=change-me
   ACCESS_TOKEN_EXPIRE_MINUTES=1440
   CORS_ORIGINS=["http://localhost:5173","http://localhost:3000"]
   OCR_TESSERACT_CMD=C:\\Program Files\\Tesseract-OCR\\tesseract.exe
   ```

6. Run the API: `uvicorn app.main:app --reload`
7. Docs at `http://localhost:8000/docs`

> **MongoDB Atlas**: set `MONGODB_URI` to your cluster string.  
> **OCR**: install [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) locally for full functionality. Without it, the endpoint returns a 503 with instructions.

### Frontend

1. `cd Frontend`
2. `flutter pub get`
3. Create `lib/core/config/app_config.dart` overrides if required (defaults to `http://localhost:8000/api/v1`).
4. Run:
   - Android/iOS: `flutter run`
   - Web/Desktop: `flutter run -d chrome`

Environment override example:

```bash
flutter run --dart-define=API_BASE_URL=https://splitbill.example.com/api/v1
```

## Testing

- Backend: add `pytest` + `httpx` tests under `Backend/tests` (template ready).
- Frontend: create widget/unit tests in `Frontend/test/` (Riverpod friendly).

## Contributing

1. Fork & clone
2. Create a feature branch
3. Make your changes + add tests
4. Submit a pull request

## Roadmap

- 🔐 OAuth / social sign-in
- 💳 Live payment provider integration (Stripe, Razorpay, etc.)
- 📊 Advanced analytics dashboard
- 🔔 Push notifications for settlements

Happy coding! 🚀


