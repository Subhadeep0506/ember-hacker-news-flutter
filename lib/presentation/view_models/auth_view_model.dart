import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../domain/models/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restoreAuth);
    return const AuthState();
  }

  Future<void> _restoreAuth() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final saved = await repo.loadSavedAuth();
      if (saved.token != null) {
        state = AuthState(token: saved.token, username: saved.username);
      }
    } catch (_) {}
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(username, password);
      state = AuthState(token: result.token, username: result.username);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e');
      return false;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState();
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
