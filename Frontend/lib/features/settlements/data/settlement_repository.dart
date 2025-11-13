import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exceptions.dart';
import '../../../shared/providers/app_providers.dart';
import '../models/settlement_model.dart';

final settlementRepositoryProvider =
    Provider<SettlementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SettlementRepository(dio);
});

class SettlementRepository {
  SettlementRepository(this._dio);

  final Dio _dio;

  Future<List<Settlement>> fetchSettlements() async {
    try {
      final response = await _dio.get<List<dynamic>>('/settlements');
      final data = response.data ?? [];
      return data
          .map((json) => Settlement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Failed to load settlements',
        error.response?.statusCode,
      );
    }
  }

  Future<Settlement> createSettlement({
    required String toUser,
    required double amount,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/settlements',
        queryParameters: {
          'to_user': toUser,
          'amount': amount,
        },
      );
      return Settlement.fromJson(response.data!);
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Failed to create settlement',
        error.response?.statusCode,
      );
    }
  }
}


