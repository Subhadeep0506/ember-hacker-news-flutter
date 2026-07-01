import 'api_client.dart';
import 'api_exception.dart';

class OgImageApiService {
  final ApiClient _client;

  OgImageApiService(this._client);

  /// Returns the og:image URL, or `null` if none found.
  /// Throws [ApiException] on 4xx/5xx JSON errors.
  /// Returns `null` silently when the response is not valid JSON
  /// (e.g. Render cold-start HTML page).
  Future<String?> getOgImage(String url) async {
    try {
      // Pass url directly in the path to avoid Uri.encodeQueryComponent
      // encoding colons/slashes — the backend expects the raw URL.
      final safeUrl = url.replaceAll('#', '%23').replaceAll('&', '%26');
      final json = await _client.get('/og-image?url=$safeUrl');
      return json['image'] as String?;
    } on FormatException {
      return null;
    }
  }
}
