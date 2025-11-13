import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/network_exceptions.dart';
import '../../../shared/providers/app_providers.dart';
import '../models/expense_models.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExpenseRepository(dio);
});

class ExpenseRepository {
  ExpenseRepository(this._dio);

  final Dio _dio;

  Future<void> createExpense(ExpenseDraft draft) async {
    try {
      await _dio.post('/expenses', data: draft.toJson());
    } on DioException catch (error) {
      throw NetworkException(
        _extractMessage(error),
        error.response?.statusCode,
      );
    }
  }

  Future<ReceiptSuggestion> parseReceipt(XFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/ocr/parse',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ReceiptSuggestion.fromJson(response.data!);
    } on DioException catch (error) {
      throw NetworkException(
        _extractMessage(error),
        error.response?.statusCode,
      );
    }
  }

  String _extractMessage(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      return (error.response!.data['detail'] ?? 'Request failed').toString();
    }
    return error.message ?? 'Request failed';
  }
}


