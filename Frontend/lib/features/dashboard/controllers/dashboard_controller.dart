import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_repository.dart';
import '../models/group_overview.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardController, List<GroupOverview>>(
        DashboardController.new);

class DashboardController extends AsyncNotifier<List<GroupOverview>> {
  late final DashboardRepository _repository;

  @override
  Future<List<GroupOverview>> build() async {
    _repository = ref.watch(dashboardRepositoryProvider);
    return _repository.fetchGroups();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.fetchGroups);
  }
}


