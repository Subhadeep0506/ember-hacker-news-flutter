import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../utils/html_unescape.dart';
import '../view_models/auth_view_model.dart';

Future<bool?> showCommentDialog(
  BuildContext context,
  WidgetRef ref, {
  required int parentId,
  String? parentAuthor,
  String? parentText,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (_) => _CommentDialogContent(
      ref: ref,
      parentId: parentId,
      parentAuthor: parentAuthor,
      parentText: parentText,
    ),
  );
}

class _CommentDialogContent extends StatefulWidget {
  final WidgetRef ref;
  final int parentId;
  final String? parentAuthor;
  final String? parentText;

  const _CommentDialogContent({
    required this.ref,
    required this.parentId,
    this.parentAuthor,
    this.parentText,
  });

  @override
  State<_CommentDialogContent> createState() => _CommentDialogContentState();
}

class _CommentDialogContentState extends State<_CommentDialogContent> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Comment cannot be empty');
      return;
    }

    final auth = widget.ref.read(authViewModelProvider);
    if (!auth.isLoggedIn || auth.token == null) {
      setState(() => _error = 'You must be logged in');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = widget.ref.read(commentRepositoryProvider);
      await repo.postComment(
        parentId: widget.parentId,
        text: text,
        token: auth.token ?? '',
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;
    final hasParent =
        widget.parentAuthor != null || widget.parentText != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasParent
                ? 'Reply to ${widget.parentAuthor ?? 'comment'}'
                : 'Add Comment',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (hasParent && widget.parentText != null) ...[
            const SizedBox(height: 12),
            _ParentPreview(
              author: widget.parentAuthor,
              text: widget.parentText ?? '',
              ember: ember,
              colorScheme: colorScheme,
            ),
          ],
          const SizedBox(height: 16),
          Flexible(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 6,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
              autofocus: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error ?? '',
              style: TextStyle(color: colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParentPreview extends StatelessWidget {
  final String? author;
  final String text;
  final EmberThemeExtension? ember;
  final ColorScheme colorScheme;

  const _ParentPreview({
    required this.author,
    required this.text,
    required this.ember,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final stripped = stripHtml(text);

    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: ember?.accentOrange ?? colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Text(
          stripped,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ember?.metadataColor,
            height: 1.4,
          ),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

}
