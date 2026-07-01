import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../domain/models/models.dart';

class ProfileState {
  final String username;
  final AsyncValue<HnUser> user;
  final AsyncValue<SearchResponse>? submissions;
  final AsyncValue<UserCommentsResponse>? comments;
  final int selectedTab;

  const ProfileState({
    this.username = '',
    this.user = const AsyncValue.loading(),
    this.submissions,
    this.comments,
    this.selectedTab = 0,
  });

  ProfileState copyWith({
    String? username,
    AsyncValue<HnUser>? user,
    AsyncValue<SearchResponse>? submissions,
    AsyncValue<UserCommentsResponse>? comments,
    int? selectedTab,
  }) {
    return ProfileState(
      username: username ?? this.username,
      user: user ?? this.user,
      submissions: submissions ?? this.submissions,
      comments: comments ?? this.comments,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadUser(String username) async {
    state = ProfileState(username: username);
    try {
      final repo = ref.read(userRepositoryProvider);
      final user = await repo.getUser(username);
      state = state.copyWith(user: AsyncValue.data(user));
      loadSubmissions();
    } catch (e, st) {
      state = state.copyWith(user: AsyncValue.error(e, st));
    }
  }

  void selectTab(int tab) {
    state = state.copyWith(selectedTab: tab);
    if (tab == 0 && state.submissions == null) {
      loadSubmissions();
    } else if (tab == 1 && state.comments == null) {
      loadComments();
    }
  }

  Future<void> loadSubmissions() async {
    state = state.copyWith(
      submissions: const AsyncValue.loading(),
    );
    try {
      final repo = ref.read(userRepositoryProvider);
      final result = await repo.getSubmissions(state.username);
      state = state.copyWith(submissions: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(submissions: AsyncValue.error(e, st));
    }
  }

  Future<void> loadComments() async {
    state = state.copyWith(
      comments: const AsyncValue.loading(),
    );
    try {
      final repo = ref.read(userRepositoryProvider);
      final result = await repo.getComments(state.username);
      state = state.copyWith(comments: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(comments: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() async {
    await loadUser(state.username);
  }
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
