import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hacker_news_flutter/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EmberApp()));
    await tester.pump();

    expect(find.text('Ember '), findsOneWidget);
  });
}
