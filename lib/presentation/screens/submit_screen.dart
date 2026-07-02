import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../utils/auth_guard.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/submit_view_model.dart';

class SubmitScreen extends ConsumerStatefulWidget {
  const SubmitScreen({super.key});

  @override
  ConsumerState<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends ConsumerState<SubmitScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    final viewModel = ref.read(submitViewModelProvider.notifier);
    final success = await viewModel.submit(
      title: title,
      url: _urlController.text.trim().isEmpty
          ? null
          : _urlController.text.trim(),
      text: _textController.text.trim().isEmpty
          ? null
          : _textController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      viewModel.reset();
      _titleController.clear();
      _urlController.clear();
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story submitted successfully!')),
      );
      context.go('/feeds');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit')),
      body: auth.isLoggedIn
          ? _SubmitForm(
              titleController: _titleController,
              urlController: _urlController,
              textController: _textController,
              username: auth.username ?? '',
              onSubmit: _handleSubmit,
            )
          : _NotLoggedInView(
              onSignIn: () async {
                await ensureLoggedIn(context, ref);
              },
            ),
    );
  }
}

class _NotLoggedInView extends StatelessWidget {
  final VoidCallback onSignIn;

  const _NotLoggedInView({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.lock, size: 48, color: ember?.metadataColor),
            const SizedBox(height: 16),
            Text(
              'Sign in to submit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You need to be logged in to submit stories to Hacker News.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ember?.metadataColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSignIn,
              icon: const Icon(AppIcons.login, size: 18),
              label: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitForm extends ConsumerWidget {
  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController textController;
  final String username;
  final VoidCallback onSubmit;

  const _SubmitForm({
    required this.titleController,
    required this.urlController,
    required this.textController,
    required this.username,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(submitViewModelProvider);
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ember?.storyCardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit a Story',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Posting as '),
                      TextSpan(
                        text: username,
                        style: TextStyle(color: ember?.accentOrange),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Text(
                  'Title',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  maxLength: 80,
                  enabled: !state.isSubmitting,
                  decoration: const InputDecoration(
                    hintText: 'Story title (max 80 characters)',
                    counterText: '',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                Text(
                  'URL',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: urlController,
                  enabled: !state.isSubmitting,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com (optional)',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                Text(
                  'Text',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  enabled: !state.isSubmitting,
                  maxLines: 6,
                  minLines: 4,
                  maxLength: 10000,
                  decoration: const InputDecoration(
                    hintText:
                        'Or write text here for an Ask HN / discussion post (optional)',
                    counterText: '',
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Submit a URL or text, not both. If you submit a URL, the title '
            'should describe what it links to. Leave the URL blank to submit '
            'a question for the HN community.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ember?.metadataColor),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error ?? '',
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.isSubmitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
