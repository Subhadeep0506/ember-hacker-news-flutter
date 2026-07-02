import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'presentation/view_models/settings_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EmberApp()));
}

class EmberApp extends ConsumerWidget {
  const EmberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final density = ref.watch(visualDensityProvider);
    final textScale = ref.watch(textScaleProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);

    return MaterialApp.router(
      title: 'Ember HN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(density: density),
      darkTheme: AppTheme.dark(density: density),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reduceMotion || media.disableAnimations,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
