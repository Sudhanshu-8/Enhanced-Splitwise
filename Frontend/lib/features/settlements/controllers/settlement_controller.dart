import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settlement_repository.dart';
import '../models/settlement_model.dart';

final settlementsProvider =
    AsyncNotifierProvider<SettlementController, List<Settlement>>(
        SettlementController.new);

class SettlementController extends AsyncNotifier<List<Settlement>> {
  late final SettlementRepository _repository;

  @override
  Future<List<Settlement>> build() async {
    _repository = ref.watch(settlementRepositoryProvider);
    return _repository.fetchSettlements();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.fetchSettlements);
  }

  Future<Settlement?> create({
    required String toUser,
    required double amount,
  }) async {
    final result =
        await AsyncValue.guard(() => _repository.createSettlement(
              toUser: toUser,
              amount: amount,
            ));
    return result.when(
      data: (settlement) {
        state = AsyncData([settlement, ...?state.value]);
        return settlement;
      },
      error: (_, __) => null,
      loading: () => null,
    );
  }
}


