import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hacker_news_flutter/main.dart';
import 'package:hacker_news_flutter/presentation/components/ember_app_bar.dart';

void main() {
  setUp(() {
    // Boot-time providers (auth restore, persisted upvotes, settings) read
    // SharedPreferences; provide an empty in-memory store so the widget test
    // doesn't hit a MissingPluginException.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots past the splash to the feed shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EmberApp()));

    // Advance past the ~2.2s splash animation, then let the feed screen build.
    // (Not pumpAndSettle: the feed's loading shimmer never settles.)
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    // The feed screen is up with its EmberAppBar — the app booted without
    // throwing through the persistence/auth-restore providers.
    expect(find.byType(EmberAppBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
