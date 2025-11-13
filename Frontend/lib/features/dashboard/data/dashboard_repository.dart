import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exceptions.dart';
import '../../../shared/providers/app_providers.dart';
import '../models/group_overview.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio);
});

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<List<GroupOverview>> fetchGroups() async {
    try {
      final response = await _dio.get<List<dynamic>>('/groups');
      final data = response.data ?? [];
      return data
          .map((json) => GroupOverview.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Failed to load groups',
        error.response?.statusCode,
      );
    }
  }
}


