String? extractDomain(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return null;
  return uri.host;
}
