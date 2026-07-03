import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/user_profile.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _aboutController = TextEditingController();
  final _emailController = TextEditingController();
  final _maxvisitController = TextEditingController();
  final _minawayController = TextEditingController();
  final _delayController = TextEditingController();
  bool _showdead = false;
  bool _noprocrast = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(editProfileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _emailController.dispose();
    _maxvisitController.dispose();
    _minawayController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _aboutController.text = profile.about ?? '';
    _emailController.text = profile.email ?? '';
    _maxvisitController.text = profile.maxvisit ?? '';
    _minawayController.text = profile.minaway ?? '';
    _delayController.text = profile.delay ?? '';
    setState(() {
      _showdead = profile.showdead == 'yes' || profile.showdead == 'true';
      _noprocrast = profile.noprocrast == 'yes' || profile.noprocrast == 'true';
    });
  }

  Future<void> _handleSave() async {
    final fields = <String, dynamic>{
      'about': _aboutController.text.trim(),
      'email': _emailController.text.trim(),
      'showdead': _showdead,
      'noprocrast': _noprocrast,
    };

    final maxvisit = int.tryParse(_maxvisitController.text.trim());
    if (maxvisit != null) fields['maxvisit'] = maxvisit;

    final minaway = int.tryParse(_minawayController.text.trim());
    if (minaway != null) fields['minaway'] = minaway;

    final delay = int.tryParse(_delayController.text.trim());
    if (delay != null) fields['delay'] = delay;

    final vm = ref.read(editProfileViewModelProvider.notifier);
    final success = await vm.updateProfile(fields);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileViewModelProvider);
    final auth = ref.watch(authViewModelProvider);
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: editState.profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.error,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('Failed to load profile',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$error',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(editProfileViewModelProvider.notifier)
                      .loadProfile(),
                  icon: const Icon(AppIcons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          _populateFields(profile);
          return _EditForm(
            aboutController: _aboutController,
            emailController: _emailController,
            maxvisitController: _maxvisitController,
            minawayController: _minawayController,
            delayController: _delayController,
            showdead: _showdead,
            noprocrast: _noprocrast,
            onShowdeadChanged: (v) => setState(() => _showdead = v),
            onNoprocrastChanged: (v) => setState(() => _noprocrast = v),
            username: auth.username ?? '',
            isSaving: editState.isSaving,
            error: editState.error,
            onSave: _handleSave,
            ember: ember,
            colorScheme: colorScheme,
          );
        },
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  final TextEditingController aboutController;
  final TextEditingController emailController;
  final TextEditingController maxvisitController;
  final TextEditingController minawayController;
  final TextEditingController delayController;
  final bool showdead;
  final bool noprocrast;
  final ValueChanged<bool> onShowdeadChanged;
  final ValueChanged<bool> onNoprocrastChanged;
  final String username;
  final bool isSaving;
  final String? error;
  final VoidCallback onSave;
  final EmberThemeExtension? ember;
  final ColorScheme colorScheme;

  const _EditForm({
    required this.aboutController,
    required this.emailController,
    required this.maxvisitController,
    required this.minawayController,
    required this.delayController,
    required this.showdead,
    required this.noprocrast,
    required this.onShowdeadChanged,
    required this.onNoprocrastChanged,
    required this.username,
    required this.isSaving,
    required this.error,
    required this.onSave,
    required this.ember,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.w600);

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
                  'Edit Profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Editing as '),
                      TextSpan(
                        text: username,
                        style: TextStyle(color: ember?.accentOrange),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                Text('About', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: aboutController,
                  enabled: !isSaving,
                  maxLines: 6,
                  minLines: 3,
                  maxLength: 10000,
                  decoration: const InputDecoration(
                    hintText: 'Tell us about yourself',
                    counterText: '',
                    alignLabelWithHint: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 20),
                Text('Email', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  enabled: !isSaving,
                  maxLength: 256,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'your@email.com',
                    counterText: '',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                _ToggleRow(
                  label: 'Show dead',
                  subtitle: 'Show dead/flagged submissions',
                  value: showdead,
                  onChanged: isSaving ? null : onShowdeadChanged,
                  ember: ember,
                ),
                const SizedBox(height: 12),
                _ToggleRow(
                  label: 'Noprocrast',
                  subtitle: 'Enable procrastination prevention',
                  value: noprocrast,
                  onChanged: isSaving ? null : onNoprocrastChanged,
                  ember: ember,
                ),
                const SizedBox(height: 20),
                Text('Max visit (minutes)', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: maxvisitController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 20',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                Text('Min away (minutes)', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: minawayController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 180',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                Text('Delay (minutes)', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: delayController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 0',
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error ?? '',
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EmberThemeExtension? ember;

  const _ToggleRow({
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.ember,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ember?.metadataColor),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: ember?.accentOrange,
        ),
      ],
    );
  }
}
