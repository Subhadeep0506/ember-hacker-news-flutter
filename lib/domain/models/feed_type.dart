enum FeedType {
  top,
  newStories,
  best,
  ask,
  show,
  job;

  String get apiValue {
    switch (this) {
      case FeedType.newStories:
        return 'new';
      default:
        return name;
    }
  }

  /// Maps a persisted settings value (e.g. 'top', 'new', 'jobs') back to a
  /// [FeedType], defaulting to [FeedType.top] for unknown values.
  static FeedType fromSettingsValue(String value) {
    switch (value) {
      case 'new':
        return FeedType.newStories;
      case 'best':
        return FeedType.best;
      case 'ask':
        return FeedType.ask;
      case 'show':
        return FeedType.show;
      case 'job':
      case 'jobs':
        return FeedType.job;
      default:
        return FeedType.top;
    }
  }

  String get displayName {
    switch (this) {
      case FeedType.top:
        return 'Top';
      case FeedType.newStories:
        return 'New';
      case FeedType.best:
        return 'Best';
      case FeedType.ask:
        return 'Ask';
      case FeedType.show:
        return 'Show';
      case FeedType.job:
        return 'Jobs';
    }
  }
}
