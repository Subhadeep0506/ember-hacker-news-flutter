import 'dart:developer';

import 'og_image_api_service.dart';

class LinkPreviewService {
  final OgImageApiService _apiService;
  final Map<String, String?> _cache = {};

  LinkPreviewService(this._apiService);

  static final _imageExtRe = RegExp(
    r'\.(?:avif|gif|jpe?g|png|webp)(?:[?#].*)?$',
    caseSensitive: false,
  );

  static final _youtubeRe = RegExp(
    r'(?:youtu\.be/|youtube\.com/(?:watch\?v=|shorts/|embed/))([\w-]{11})',
  );

  Future<String?> fetchOgImage(String url) async {
    if (_cache.containsKey(url)) return _cache[url];

    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) {
      _cache[url] = null;
      return null;
    }

    final youtube = _youtubeImage(url);
    if (youtube != null) {
      _cache[url] = youtube;
      return youtube;
    }

    if (_imageExtRe.hasMatch(parsed.path)) {
      _cache[url] = url;
      return url;
    }

    try {
      final image = await _apiService.getOgImage(url);
      _cache[url] = image;
      return image;
    } catch (e) {
      log('Failed to fetch og:image for $url: $e', name: 'LinkPreview');
      _cache[url] = null;
      return null;
    }
  }

  String? _youtubeImage(String url) {
    final match = _youtubeRe.firstMatch(url);
    if (match == null) return null;
    return 'https://i.ytimg.com/vi/${match.group(1)}/hqdefault.jpg';
  }
}
