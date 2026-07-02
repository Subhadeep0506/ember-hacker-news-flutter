String? extractDomain(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;
  return uri.host;
}

/// Google's favicon service URL for the host of [url], or `null` when the URL
/// has no resolvable host. [size] is the requested icon size in pixels.
String? faviconUrl(String? url, {int size = 64}) {
  final host = extractDomain(url);
  if (host == null) return null;
  return 'https://www.google.com/s2/favicons?domain=$host&sz=$size';
}
