import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/auth_token_provider.dart';
import '../data/auth_repository.dart';
import '../models/auth_user.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
  late final AuthRepository _repository;
  late final SecureStorage _storage;

  @override
  Future<AuthUser?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    _storage = ref.watch(secureStorageProvider);

    final token = await _storage.readToken();
    if (token == null) {
      return null;
    }
    ref.read(authTokenProvider.notifier).state = token;
    try {
      final user = await _repository.currentUser();
      return user;
    } catch (_) {
      await _storage.clearToken();
      ref.read(authTokenProvider.notifier).state = null;
      return null;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = await _repository.login(email: email, password: password);
      await _storage.saveToken(token);
      ref.read(authTokenProvider.notifier).state = token;
      final user = await _repository.currentUser();
      return user;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      final token = await _repository.login(email: email, password: password);
      await _storage.saveToken(token);
      ref.read(authTokenProvider.notifier).state = token;
      final user = await _repository.currentUser();
      return user;
    });
  }

  Future<void> logout() async {
    await _storage.clearToken();
    ref.read(authTokenProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}


