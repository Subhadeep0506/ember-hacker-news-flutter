class SettingsState {
  final String themeMode;
  final double textSizePercent;
  final bool serifForArticles;
  final String density;
  final bool reduceMotion;

  final String defaultFeedType;
  final bool markReadOnScroll;
  final bool showDomainBadges;
  final bool hideJobPosts;

  final int autoCollapseDepth;
  final bool highlightOP;
  final bool showDeadDeleted;

  final String openExternalLinks;
  final bool readerModeDefault;

  final String defaultSort;

  const SettingsState({
    this.themeMode = 'auto',
    this.textSizePercent = 100,
    this.serifForArticles = true,
    this.density = 'cozy',
    this.reduceMotion = false,
    this.defaultFeedType = 'top',
    this.markReadOnScroll = false,
    this.showDomainBadges = true,
    this.hideJobPosts = false,
    this.autoCollapseDepth = 0,
    this.highlightOP = true,
    this.showDeadDeleted = false,
    this.openExternalLinks = 'in_app',
    this.readerModeDefault = false,
    this.defaultSort = 'relevance',
  });

  SettingsState copyWith({
    String? themeMode,
    double? textSizePercent,
    bool? serifForArticles,
    String? density,
    bool? reduceMotion,
    String? defaultFeedType,
    bool? markReadOnScroll,
    bool? showDomainBadges,
    bool? hideJobPosts,
    int? autoCollapseDepth,
    bool? highlightOP,
    bool? showDeadDeleted,
    String? openExternalLinks,
    bool? readerModeDefault,
    String? defaultSort,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      textSizePercent: textSizePercent ?? this.textSizePercent,
      serifForArticles: serifForArticles ?? this.serifForArticles,
      density: density ?? this.density,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      defaultFeedType: defaultFeedType ?? this.defaultFeedType,
      markReadOnScroll: markReadOnScroll ?? this.markReadOnScroll,
      showDomainBadges: showDomainBadges ?? this.showDomainBadges,
      hideJobPosts: hideJobPosts ?? this.hideJobPosts,
      autoCollapseDepth: autoCollapseDepth ?? this.autoCollapseDepth,
      highlightOP: highlightOP ?? this.highlightOP,
      showDeadDeleted: showDeadDeleted ?? this.showDeadDeleted,
      openExternalLinks: openExternalLinks ?? this.openExternalLinks,
      readerModeDefault: readerModeDefault ?? this.readerModeDefault,
      defaultSort: defaultSort ?? this.defaultSort,
    );
  }
}
