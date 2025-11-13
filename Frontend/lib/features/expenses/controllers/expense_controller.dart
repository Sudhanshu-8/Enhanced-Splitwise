import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/expense_repository.dart';
import '../models/expense_models.dart';

final expenseControllerProvider =
    AutoDisposeAsyncNotifierProvider<ExpenseController, void>(
  ExpenseController.new,
);

final receiptSuggestionProvider =
    StateProvider.autoDispose<ReceiptSuggestion?>((ref) => null);

class ExpenseController extends AutoDisposeAsyncNotifier<void> {
  late final ExpenseRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(expenseRepositoryProvider);
  }

  Future<void> createExpense(ExpenseDraft draft) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.createExpense(draft));
  }

  Future<void> parseReceipt(XFile file) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final suggestion = await _repository.parseReceipt(file);
      ref.read(receiptSuggestionProvider.notifier).state = suggestion;
    });
  }

  void clearSuggestion() {
    ref.read(receiptSuggestionProvider.notifier).state = null;
  }
}


