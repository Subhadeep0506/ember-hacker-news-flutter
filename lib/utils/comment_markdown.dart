import 'package:markdown/markdown.dart' as markdown;

String renderCommentMarkdown(String text) {
  if (text.trim().isEmpty) {
    return '';
  }

  return markdown.markdownToHtml(
    text,
    extensionSet: markdown.ExtensionSet.gitHubWeb,
  );
}
