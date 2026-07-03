final _entityMap = {
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&apos;': "'",
  '&#x27;': "'",
  '&#x2F;': '/',
  '&#39;': "'",
  '&#47;': '/',
  '&nbsp;': ' ',
  '&ndash;': '–',
  '&mdash;': '—',
  '&lsquo;': '‘',
  '&rsquo;': '’',
  '&ldquo;': '“',
  '&rdquo;': '”',
  '&hellip;': '…',
};

final _entityPattern = RegExp(
  r'&(?:#x([0-9a-fA-F]+)|#(\d+)|(\w+));',
);

String htmlUnescape(String input) {
  return input.replaceAllMapped(_entityPattern, (match) {
    final full = match[0]!;
    if (_entityMap.containsKey(full)) return _entityMap[full]!;
    final hex = match[1];
    if (hex != null) return String.fromCharCode(int.parse(hex, radix: 16));
    final dec = match[2];
    if (dec != null) return String.fromCharCode(int.parse(dec));
    return full;
  });
}

String stripHtml(String html) {
  return htmlUnescape(
    html
        .replaceAll(RegExp(r'<p>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim(),
  );
}
