import '../../domain/models/settings_state.dart';
import '../local/settings_dao.dart';

class SettingsRepository {
  final SettingsDao _dao;

  static const keyThemeMode = 'theme_mode';
  static const keyTextSizePercent = 'text_size_percent';
  static const keySerifForArticles = 'serif_for_articles';
  static const keyDensity = 'density';
  static const keyReduceMotion = 'reduce_motion';
  static const keyDefaultFeedType = 'default_feed_type';
  static const keyMarkReadOnScroll = 'mark_read_on_scroll';
  static const keyShowDomainBadges = 'show_domain_badges';
  static const keyHideJobPosts = 'hide_job_posts';
  static const keyAutoCollapseDepth = 'auto_collapse_depth';
  static const keyHighlightOP = 'highlight_op';
  static const keyShowDeadDeleted = 'show_dead_deleted';
  static const keyOpenExternalLinks = 'open_external_links';
  static const keyReaderModeDefault = 'reader_mode_default';
  static const keyDefaultSort = 'default_sort';
  static const keyNotifyReplies = 'notify_replies';
  static const keyNotifyMentions = 'notify_mentions';
  static const keyOptOutAnalytics = 'opt_out_analytics';

  static const _allKeys = [
    keyThemeMode,
    keyTextSizePercent,
    keySerifForArticles,
    keyDensity,
    keyReduceMotion,
    keyDefaultFeedType,
    keyMarkReadOnScroll,
    keyShowDomainBadges,
    keyHideJobPosts,
    keyAutoCollapseDepth,
    keyHighlightOP,
    keyShowDeadDeleted,
    keyOpenExternalLinks,
    keyReaderModeDefault,
    keyDefaultSort,
    keyNotifyReplies,
    keyNotifyMentions,
    keyOptOutAnalytics,
  ];

  SettingsRepository(this._dao);

  Future<SettingsState> loadAll() async {
    final all = await _dao.getAll();
    return SettingsState(
      themeMode: all[keyThemeMode] ?? 'auto',
      textSizePercent:
          double.tryParse(all[keyTextSizePercent] ?? '') ?? 100,
      serifForArticles: _parseBool(all[keySerifForArticles], true),
      density: all[keyDensity] ?? 'cozy',
      reduceMotion: _parseBool(all[keyReduceMotion], false),
      defaultFeedType: all[keyDefaultFeedType] ?? 'top',
      markReadOnScroll: _parseBool(all[keyMarkReadOnScroll], false),
      showDomainBadges: _parseBool(all[keyShowDomainBadges], true),
      hideJobPosts: _parseBool(all[keyHideJobPosts], false),
      autoCollapseDepth:
          int.tryParse(all[keyAutoCollapseDepth] ?? '') ?? 0,
      highlightOP: _parseBool(all[keyHighlightOP], true),
      showDeadDeleted: _parseBool(all[keyShowDeadDeleted], false),
      openExternalLinks: all[keyOpenExternalLinks] ?? 'in_app',
      readerModeDefault: _parseBool(all[keyReaderModeDefault], false),
      defaultSort: all[keyDefaultSort] ?? 'relevance',
      notifyReplies: _parseBool(all[keyNotifyReplies], false),
      notifyMentions: _parseBool(all[keyNotifyMentions], false),
      optOutAnalytics: _parseBool(all[keyOptOutAnalytics], false),
    );
  }

  Future<void> save(String key, String value) => _dao.set(key, value);

  Future<void> resetAll() async {
    for (final key in _allKeys) {
      await _dao.delete(key);
    }
  }

  bool _parseBool(String? value, bool defaultValue) {
    if (value == null) return defaultValue;
    return value == 'true';
  }
}
