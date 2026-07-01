import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../view_models/auth_view_model.dart';

Future<bool?> showLoginDialog(BuildContext context, WidgetRef ref) {
  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _LoginDialogContent(ref: ref),
      ),
    ),
  );
}

class _LoginDialogContent extends StatefulWidget {
  final WidgetRef ref;

  const _LoginDialogContent({required this.ref});

  @override
  State<_LoginDialogContent> createState() => _LoginDialogContentState();
}

class _LoginDialogContentState extends State<_LoginDialogContent> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Username and password required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final viewModel = widget.ref.read(authViewModelProvider.notifier);
    final success = await viewModel.login(username, password);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final authState = widget.ref.read(authViewModelProvider);
      setState(() {
        _isLoading = false;
        _error = authState.error ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sign in to Hacker News',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(false),
                icon: const Icon(AppIcons.close),
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with your Hacker News account to upvote, comment, and submit.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ember?.metadataColor,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error ?? '',
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(AppIcons.login, size: 18),
            label: const Text('Sign in'),
            style: FilledButton.styleFrom(
              backgroundColor: ember?.accentOrange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
