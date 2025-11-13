import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/secure_storage.dart';
import 'auth_token_provider.dart';

final appConfigProvider = Provider<AppConfig>((ref) => defaultConfig);

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final token = ref.watch(authTokenProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ),
  );

  // Add auth interceptor to handle token updates dynamically
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get the latest token from the provider
        final currentToken = ref.read(authTokenProvider);
        if (currentToken != null) {
          options.headers['Authorization'] = 'Bearer $currentToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 unauthorized - clear token
        if (error.response?.statusCode == 401) {
          ref.read(authTokenProvider.notifier).state = null;
        }
        handler.next(error);
      },
    ),
  );

  // Enable logging for debugging
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        // Print to console for debugging
        print('[Dio] $obj');
      },
    ),
  );

  return dio;
});


