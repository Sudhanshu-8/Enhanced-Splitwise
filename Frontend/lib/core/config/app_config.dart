import 'dart:io';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
  });

  final String apiBaseUrl;

  static String getDefaultBaseUrl() {
    final envUrl = const String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    // For Android emulator, use 10.0.2.2 instead of localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    // For iOS simulator, localhost works
    if (Platform.isIOS) {
      return 'http://localhost:8000/api/v1';
    }
    // Default fallback
    return 'http://localhost:8000/api/v1';
  }
}

final defaultConfig = AppConfig(
  apiBaseUrl: AppConfig.getDefaultBaseUrl(),
);


