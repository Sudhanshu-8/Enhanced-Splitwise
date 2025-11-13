# Enhanced SplitBill – Flutter Frontend

Modern mobile app that powers the Enhanced Splitwise experience. It uses Flutter + Riverpod to deliver a polished UI with OCR-assisted expense creation, group dashboards, and settlement flows.

## Features

- Animated splash & auth onboarding flow
- Riverpod + GoRouter architecture (scalable, testable)
- Dashboard with live group balances
- OCR-driven expense entry with image picker
- Settlement manager showcasing payment links
- Profile page with secure logout & settings

## Tech Stack

- Flutter 3.24+
- Riverpod 2
- GoRouter 14
- Dio HTTP client
- FlexColorScheme + Google Fonts for theming

## Getting Started

```bash
flutter pub get
flutter run
```

By default the app points to `http://localhost:8000/api/v1`. Override when needed:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### Platform Notes

- **iOS**: Add the following to `ios/Runner/Info.plist` for receipt scanning:

  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>SplitBill needs access to your photo library to attach receipts.</string>
  <key>NSCameraUsageDescription</key>
  <string>SplitBill uses the camera to scan receipts.</string>
  ```

- **Android**: Image picker permissions are auto-declared via the plugin; ensure you have `compileSdkVersion` ≥ 34.

## Testing

- Add widget/unit tests under `test/`
- Use `flutter test --coverage` for reports

## Folder Highlights

- `lib/core` – theming, config, storage, networking
- `lib/features` – feature slices (auth, dashboard, expenses, etc.)
- `lib/shared` – reusable widgets & providers
- `lib/router` – centralized navigation graph

Happy hacking! 🚀
