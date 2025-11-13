import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exceptions.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/auth_token_provider.dart';
import '../models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthUser> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      return AuthUser.fromJson(response.data!);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final data = response.data!;
      return data['access_token'] as String;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<AuthUser> currentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/me');
      return AuthUser.fromJson(response.data!);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  NetworkException _mapError(DioException error) {
    final message = error.response?.data is Map<String, dynamic>
        ? (error.response!.data['detail']?.toString() ?? 'Request failed')
        : error.message ?? 'Request failed';
    return NetworkException(message, error.response?.statusCode);
  }
}


