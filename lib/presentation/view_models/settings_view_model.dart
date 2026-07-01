import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/settings_state.dart';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    Future.microtask(_loadSettings);
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      state = await repo.loadAll();
    } catch (_) {}
  }

  Future<void> _save(String key, String value) async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.save(key, value);
    } catch (_) {}
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _save(SettingsRepository.keyThemeMode, mode);
  }

  Future<void> setTextSize(double percent) async {
    state = state.copyWith(textSizePercent: percent);
    await _save(SettingsRepository.keyTextSizePercent, '$percent');
  }

  Future<void> setSerifForArticles(bool enabled) async {
    state = state.copyWith(serifForArticles: enabled);
    await _save(SettingsRepository.keySerifForArticles, '$enabled');
  }

  Future<void> setDensity(String density) async {
    state = state.copyWith(density: density);
    await _save(SettingsRepository.keyDensity, density);
  }

  Future<void> setReduceMotion(bool enabled) async {
    state = state.copyWith(reduceMotion: enabled);
    await _save(SettingsRepository.keyReduceMotion, '$enabled');
  }

  Future<void> setDefaultFeedType(String type) async {
    state = state.copyWith(defaultFeedType: type);
    await _save(SettingsRepository.keyDefaultFeedType, type);
  }

  Future<void> setMarkReadOnScroll(bool enabled) async {
    state = state.copyWith(markReadOnScroll: enabled);
    await _save(SettingsRepository.keyMarkReadOnScroll, '$enabled');
  }

  Future<void> setShowDomainBadges(bool enabled) async {
    state = state.copyWith(showDomainBadges: enabled);
    await _save(SettingsRepository.keyShowDomainBadges, '$enabled');
  }

  Future<void> setHideJobPosts(bool enabled) async {
    state = state.copyWith(hideJobPosts: enabled);
    await _save(SettingsRepository.keyHideJobPosts, '$enabled');
  }

  Future<void> setAutoCollapseDepth(int depth) async {
    state = state.copyWith(autoCollapseDepth: depth);
    await _save(SettingsRepository.keyAutoCollapseDepth, '$depth');
  }

  Future<void> setHighlightOP(bool enabled) async {
    state = state.copyWith(highlightOP: enabled);
    await _save(SettingsRepository.keyHighlightOP, '$enabled');
  }

  Future<void> setShowDeadDeleted(bool enabled) async {
    state = state.copyWith(showDeadDeleted: enabled);
    await _save(SettingsRepository.keyShowDeadDeleted, '$enabled');
  }

  Future<void> setOpenExternalLinks(String mode) async {
    state = state.copyWith(openExternalLinks: mode);
    await _save(SettingsRepository.keyOpenExternalLinks, mode);
  }

  Future<void> setReaderModeDefault(bool enabled) async {
    state = state.copyWith(readerModeDefault: enabled);
    await _save(SettingsRepository.keyReaderModeDefault, '$enabled');
  }

  Future<void> setDefaultSort(String sort) async {
    state = state.copyWith(defaultSort: sort);
    await _save(SettingsRepository.keyDefaultSort, sort);
  }

  Future<void> setNotifyReplies(bool enabled) async {
    state = state.copyWith(notifyReplies: enabled);
    await _save(SettingsRepository.keyNotifyReplies, '$enabled');
  }

  Future<void> setNotifyMentions(bool enabled) async {
    state = state.copyWith(notifyMentions: enabled);
    await _save(SettingsRepository.keyNotifyMentions, '$enabled');
  }

  Future<void> setOptOutAnalytics(bool enabled) async {
    state = state.copyWith(optOutAnalytics: enabled);
    await _save(SettingsRepository.keyOptOutAnalytics, '$enabled');
  }

  Future<void> clearReadHistory() async {
    try {
      final dao = ref.read(readHistoryDaoProvider);
      await dao.clearAll();
    } catch (_) {}
  }

  Future<void> clearCachedStories() async {
    try {
      final dao = ref.read(storyDaoProvider);
      await dao.clearAllCaches();
    } catch (_) {}
  }

  Future<void> resetAllSettings() async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.resetAll();
      state = const SettingsState();
    } catch (_) {}
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsViewModelProvider);
  switch (settings.themeMode) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});
