import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../domain/models/user_profile.dart';
import 'auth_view_model.dart';

class EditProfileState {
  final bool isSaving;
  final AsyncValue<UserProfile> profile;
  final String? error;
  final bool isSuccess;

  const EditProfileState({
    this.isSaving = false,
    this.profile = const AsyncValue.loading(),
    this.error,
    this.isSuccess = false,
  });

  EditProfileState copyWith({
    bool? isSaving,
    AsyncValue<UserProfile>? profile,
    String? error,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return EditProfileState(
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class EditProfileViewModel extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  Future<void> loadProfile() async {
    final auth = ref.read(authViewModelProvider);
    if (!auth.isLoggedIn || auth.token == null) return;

    state = const EditProfileState();
    try {
      final repo = ref.read(authRepositoryProvider);
      final profile = await repo.getMe(token: auth.token!);
      state = EditProfileState(profile: AsyncValue.data(profile));
    } catch (e, st) {
      state = EditProfileState(profile: AsyncValue.error(e, st));
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    final auth = ref.read(authViewModelProvider);
    if (!auth.isLoggedIn || auth.token == null) return false;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateMe(token: auth.token!, fields: fields);
      state = state.copyWith(isSaving: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '$e');
      return false;
    }
  }

  void reset() {
    state = const EditProfileState();
  }
}

final editProfileViewModelProvider =
    NotifierProvider<EditProfileViewModel, EditProfileState>(
  EditProfileViewModel.new,
);
