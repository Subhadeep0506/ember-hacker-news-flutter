import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_client.dart';
import '../../data/api/auth_api_service.dart';
import '../../data/api/comment_api_service.dart';
import '../../data/api/feed_api_service.dart';
import '../../data/api/link_preview_service.dart';
import '../../data/api/og_image_api_service.dart';
import '../../data/api/search_api_service.dart';
import '../../data/api/submit_api_service.dart';
import '../../data/api/user_api_service.dart';
import '../../data/api/vote_api_service.dart';
import '../../data/local/read_history_dao.dart';
import '../../data/local/settings_dao.dart';
import '../../data/local/story_dao.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/submit_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/vote_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final feedApiServiceProvider = Provider<FeedApiService>(
  (ref) => FeedApiService(ref.watch(apiClientProvider)),
);

final searchApiServiceProvider = Provider<SearchApiService>(
  (ref) => SearchApiService(ref.watch(apiClientProvider)),
);

final storyDaoProvider = Provider<StoryDao>((ref) => StoryDao());

final readHistoryDaoProvider = Provider<ReadHistoryDao>(
  (ref) => ReadHistoryDao(),
);

final settingsDaoProvider = Provider<SettingsDao>((ref) => SettingsDao());

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(
    ref.watch(feedApiServiceProvider),
    ref.watch(storyDaoProvider),
    ref.watch(readHistoryDaoProvider),
  ),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(searchApiServiceProvider)),
);

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(feedApiServiceProvider)),
);

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(settingsDaoProvider),
  ),
);

final voteApiServiceProvider = Provider<VoteApiService>(
  (ref) => VoteApiService(ref.watch(apiClientProvider)),
);

final voteRepositoryProvider = Provider<VoteRepository>(
  (ref) => VoteRepository(ref.watch(voteApiServiceProvider)),
);

final commentApiServiceProvider = Provider<CommentApiService>(
  (ref) => CommentApiService(ref.watch(apiClientProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(commentApiServiceProvider)),
);

final ogImageApiServiceProvider = Provider<OgImageApiService>(
  (ref) => OgImageApiService(ref.watch(apiClientProvider)),
);

final linkPreviewServiceProvider = Provider<LinkPreviewService>(
  (ref) => LinkPreviewService(ref.watch(ogImageApiServiceProvider)),
);

final ogImageProvider = FutureProvider.family<String?, String>((ref, url) async {
  ref.keepAlive();
  final service = ref.read(linkPreviewServiceProvider);
  return service.fetchOgImage(url);
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(settingsDaoProvider)),
);

final submitApiServiceProvider = Provider<SubmitApiService>(
  (ref) => SubmitApiService(ref.watch(apiClientProvider)),
);

final submitRepositoryProvider = Provider<SubmitRepository>(
  (ref) => SubmitRepository(ref.watch(submitApiServiceProvider)),
);

final userApiServiceProvider = Provider<UserApiService>(
  (ref) => UserApiService(ref.watch(apiClientProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(userApiServiceProvider)),
);
