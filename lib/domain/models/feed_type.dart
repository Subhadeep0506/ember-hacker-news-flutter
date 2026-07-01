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
