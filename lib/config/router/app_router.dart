import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/app_shell.dart';
import '../../presentation/screens/feed_screen.dart';
import '../../presentation/screens/in_app_browser_screen.dart';
import '../../presentation/screens/post_detail_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/submit_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/feeds',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/feeds',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FeedScreen()),
            routes: [
              GoRoute(
                path: 'post/:id',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return PostDetailScreen(itemId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SearchScreen()),
            routes: [
              GoRoute(
                path: 'post/:id',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return PostDetailScreen(itemId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/submit',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SubmitScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/:username',
        builder: (context, state) {
          final username = state.pathParameters['username'] ?? '';
          return ProfileScreen(username: username);
        },
      ),
      GoRoute(
        path: '/browser',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is Map<String, dynamic> ? extra : const {};
          return InAppBrowserScreen(
            url: args['url'] as String? ?? '',
            readerMode: args['reader'] as bool? ?? false,
          );
        },
      ),
    ],
  );
});
