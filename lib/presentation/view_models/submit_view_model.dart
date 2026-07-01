import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import 'auth_view_model.dart';

class SubmitState {
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  const SubmitState({
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  SubmitState copyWith({
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return SubmitState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SubmitViewModel extends Notifier<SubmitState> {
  @override
  SubmitState build() => const SubmitState();

  Future<bool> submit({
    required String title,
    String? url,
    String? text,
  }) async {
    final auth = ref.read(authViewModelProvider);
    if (!auth.isLoggedIn || auth.token == null) return false;

    state = const SubmitState(isSubmitting: true);

    try {
      final repo = ref.read(submitRepositoryProvider);
      await repo.submitPost(
        title: title,
        url: url,
        text: text,
        token: auth.token ?? '',
      );
      state = const SubmitState(isSuccess: true);
      return true;
    } catch (e) {
      state = SubmitState(error: '$e');
      return false;
    }
  }

  void reset() {
    state = const SubmitState();
  }
}

final submitViewModelProvider =
    NotifierProvider<SubmitViewModel, SubmitState>(SubmitViewModel.new);
