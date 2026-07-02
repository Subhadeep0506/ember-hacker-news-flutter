import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/theme/app_icons.dart';

/// Full-screen in-app browser backed by [WebView]. Reachable only on mobile
/// (webview_flutter has no web support); links on web fall back to the system
/// browser before this screen is ever pushed (see `openLink`).
class InAppBrowserScreen extends StatefulWidget {
  final String url;
  final bool readerMode;

  const InAppBrowserScreen({
    super.key,
    required this.url,
    this.readerMode = false,
  });

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
          onPageFinished: (url) async {
            final title = await _controller.getTitle();
            if (widget.readerMode) {
              await _controller.runJavaScript(_readerScript);
            }
            if (mounted) setState(() => _title = title ?? '');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final host = Uri.tryParse(widget.url)?.host ?? widget.url;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title.isEmpty ? 'Loading…' : _title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              host,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: 'Reload',
          ),
          IconButton(
            icon: const Icon(AppIcons.openExternal),
            onPressed: _openExternally,
            tooltip: 'Open in browser',
          ),
        ],
        bottom: _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

/// Best-effort reader mode: promotes the most text-dense container to the top
/// of the document and applies a clean, centered reading column.
const String _readerScript = '''
(function() {
  try {
    var candidates = document.querySelectorAll('article, main, [role=main], .post, .article, .content');
    var best = null, bestLen = 0;
    var pool = candidates.length ? candidates : document.querySelectorAll('div, section');
    pool.forEach(function(el) {
      var len = (el.innerText || '').length;
      if (len > bestLen) { bestLen = len; best = el; }
    });
    if (best && bestLen > 200) {
      var html = best.innerHTML;
      document.body.innerHTML = '<div id="ember-reader">' + html + '</div>';
    }
    var style = document.createElement('style');
    style.innerHTML =
      'body{background:#fff;color:#111;} ' +
      '#ember-reader,body{max-width:680px;margin:0 auto;padding:20px;' +
      'font-family:Georgia,serif;font-size:19px;line-height:1.6;} ' +
      '#ember-reader img{max-width:100%;height:auto;}';
    document.head.appendChild(style);
  } catch (e) {}
})();
''';
