import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../presentation/view_models/settings_view_model.dart';

/// Central entry point for opening a web link, honouring the user's
/// "Open external links" and "Reader mode" settings.
///
/// On mobile with in-app mode enabled, the URL is pushed onto the in-app
/// browser route. `webview_flutter` has no web support, so on web (and when the
/// external mode is selected) we fall back to the system browser / a new tab.
Future<void> openLink(BuildContext context, WidgetRef ref, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || url.isEmpty) return;

  final openInApp = ref.read(openInAppProvider);
  if (openInApp && !kIsWeb) {
    final reader = ref.read(readerModeProvider);
    context.push('/browser', extra: {'url': url, 'reader': reader});
    return;
  }

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}
