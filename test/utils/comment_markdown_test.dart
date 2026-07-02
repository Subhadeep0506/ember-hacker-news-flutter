import 'package:flutter_test/flutter_test.dart';
import 'package:hacker_news_flutter/utils/comment_markdown.dart';

void main() {
  group('renderCommentMarkdown', () {
    test('renders emphasis markdown as HTML', () {
      final html = renderCommentMarkdown('This is **bold** and _italic_.');

      expect(html, contains('<strong>bold</strong>'));
      expect(html, contains('<em>italic</em>'));
    });

    test('renders markdown links as anchors', () {
      final html = renderCommentMarkdown(
        '[Hacker News](https://news.ycombinator.com)',
      );

      expect(
        html,
        contains('<a href="https://news.ycombinator.com">Hacker News</a>'),
      );
    });

    test('renders inline code markdown as code tags', () {
      final html = renderCommentMarkdown('Use `final count = 1;` here.');

      expect(html, contains('<code>final count = 1;</code>'));
    });

    test('preserves existing HTML-shaped Hacker News content', () {
      final html = renderCommentMarkdown(
        'Read <a href="https://example.com">this</a><p>Second paragraph',
      );

      expect(html, contains('<a href="https://example.com">this</a>'));
      expect(html, contains('<p>Second paragraph'));
    });

    test('returns empty output for blank comment text', () {
      expect(renderCommentMarkdown('   '), isEmpty);
    });
  });
}
