import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/settings_state.dart';
import '../components/ember_chip.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginLoading = false;
  String? _loginError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _loginError = 'Username and password required');
      return;
    }

    setState(() {
      _isLoginLoading = true;
      _loginError = null;
    });

    final success =
        await ref.read(authViewModelProvider.notifier).login(username, password);

    if (!mounted) return;

    if (success) {
      _usernameController.clear();
      _passwordController.clear();
      setState(() {
        _isLoginLoading = false;
        _loginError = null;
      });
    } else {
      final authState = ref.read(authViewModelProvider);
      setState(() {
        _isLoginLoading = false;
        _loginError = authState.error ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider);
    final settings = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 72,
        ),
        children: [
          _buildAccountSection(auth, ember),
          _buildAppearanceSection(settings, vm, ember),
          _buildFeedSection(settings, vm, ember),
          _buildCommentsSection(settings, vm, ember),
          _buildReadingSection(settings, vm, ember),
          _buildSearchSection(settings, vm, ember),
          _buildNotificationsSection(settings, vm, ember, auth.isLoggedIn),
          _buildPrivacySection(settings, vm, ember),
          _buildDataSection(vm, ember),
          _buildAboutSection(ember),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Ember is an independent client for Hacker News. Not affiliated with Y Combinator.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ember?.metadataColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── ACCOUNT ────────────────────────────────────────────────────────

  Widget _buildAccountSection(
    dynamic auth,
    EmberThemeExtension? ember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.user, label: 'ACCOUNT'),
        _SettingsCard(
          children: [
            if (auth.isLoggedIn)
              _buildLoggedInAccount(auth, ember)
            else
              _buildLoggedOutAccount(ember),
          ],
        ),
      ],
    );
  }

  Widget _buildLoggedInAccount(dynamic auth, EmberThemeExtension? ember) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ember?.accentOrange,
            child: Text(
              (auth.username ?? '?')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.username ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Logged in',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ember?.metadataColor,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () =>
                ref.read(authViewModelProvider.notifier).logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutAccount(EmberThemeExtension? ember) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(AppIcons.login, color: ember?.metadataColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Not signed in',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in with your Hacker News account to upvote, comment, and submit. We store an encrypted session cookie — never your password.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ember?.metadataColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'HN username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textInputAction: TextInputAction.next,
            enabled: !_isLoginLoading,
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
            enabled: !_isLoginLoading,
            onSubmitted: (_) => _handleLogin(),
          ),
          if (_loginError != null) ...[
            const SizedBox(height: 8),
            Text(
              _loginError ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLoginLoading ? null : _handleLogin,
            icon: _isLoginLoading
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

  // ─── APPEARANCE ─────────────────────────────────────────────────────

  Widget _buildAppearanceSection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.palette, label: 'APPEARANCE'),
        _SettingsCard(
          children: [
            _ChipRow(
              title: 'Theme',
              subtitle: 'System follows your device.',
              options: const [
                (value: 'auto', label: 'Auto', icon: AppIcons.themeSystem),
                (value: 'dark', label: 'Dark', icon: AppIcons.themeDark),
                (value: 'light', label: 'Light', icon: AppIcons.themeLight),
              ],
              selected: settings.themeMode,
              onSelected: vm.setThemeMode,
            ),
            const Divider(height: 0),
            _SliderRow(
              title: 'Text size',
              valueLabel: '${settings.textSizePercent.round()}%',
              value: settings.textSizePercent,
              min: 50,
              max: 200,
              divisions: 15,
              onChanged: vm.setTextSize,
              ember: ember,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Serif for article text',
              subtitle: 'Use a serif font in story bodies and comments.',
              value: settings.serifForArticles,
              onChanged: vm.setSerifForArticles,
              ember: ember,
            ),
            const Divider(height: 0),
            _ChipRow(
              title: 'Density',
              options: const [
                (value: 'cozy', label: 'Cozy', icon: null),
                (value: 'compact', label: 'Compact', icon: null),
              ],
              selected: settings.density,
              onSelected: vm.setDensity,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Reduce motion',
              subtitle: 'Minimise animations and transitions.',
              value: settings.reduceMotion,
              onChanged: vm.setReduceMotion,
              ember: ember,
            ),
          ],
        ),
      ],
    );
  }

  // ─── FEED ───────────────────────────────────────────────────────────

  Widget _buildFeedSection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.feedSection, label: 'FEED'),
        _SettingsCard(
          children: [
            _ChipRow(
              title: 'Default feed',
              options: const [
                (value: 'top', label: 'Top', icon: null),
                (value: 'new', label: 'New', icon: null),
                (value: 'best', label: 'Best', icon: null),
                (value: 'ask', label: 'Ask', icon: null),
                (value: 'show', label: 'Show', icon: null),
                (value: 'job', label: 'Jobs', icon: null),
              ],
              selected: settings.defaultFeedType,
              onSelected: vm.setDefaultFeedType,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Mark read on scroll',
              value: settings.markReadOnScroll,
              onChanged: vm.setMarkReadOnScroll,
              ember: ember,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Show domain badges',
              value: settings.showDomainBadges,
              onChanged: vm.setShowDomainBadges,
              ember: ember,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Hide job posts in mixed feed',
              value: settings.hideJobPosts,
              onChanged: vm.setHideJobPosts,
              ember: ember,
            ),
          ],
        ),
      ],
    );
  }

  // ─── COMMENTS ───────────────────────────────────────────────────────

  Widget _buildCommentsSection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
  ) {
    final depthLabel =
        settings.autoCollapseDepth == 0
            ? 'Off'
            : '${settings.autoCollapseDepth}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: AppIcons.comment,
          label: 'COMMENTS',
        ),
        _SettingsCard(
          children: [
            _SliderRow(
              title: 'Auto-collapse below depth',
              valueLabel: depthLabel,
              value: settings.autoCollapseDepth.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) => vm.setAutoCollapseDepth(v.round()),
              ember: ember,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Highlight original poster',
              value: settings.highlightOP,
              onChanged: vm.setHighlightOP,
              ember: ember,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Show dead & deleted comments',
              value: settings.showDeadDeleted,
              onChanged: vm.setShowDeadDeleted,
              ember: ember,
            ),
          ],
        ),
      ],
    );
  }

  // ─── READING ────────────────────────────────────────────────────────

  Widget _buildReadingSection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.stories, label: 'READING'),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Open external links',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  DropdownButton<String>(
                    value: settings.openExternalLinks,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(
                        value: 'in_app',
                        child: Text('In-app'),
                      ),
                      DropdownMenuItem(
                        value: 'external',
                        child: Text('External'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) vm.setOpenExternalLinks(v);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Reader mode by default',
              subtitle: 'Strip ads and chrome where possible.',
              value: settings.readerModeDefault,
              onChanged: vm.setReaderModeDefault,
              ember: ember,
            ),
          ],
        ),
      ],
    );
  }

  // ─── SEARCH ─────────────────────────────────────────────────────────

  Widget _buildSearchSection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.search, label: 'SEARCH'),
        _SettingsCard(
          children: [
            _ChipRow(
              title: 'Default sort',
              options: const [
                (value: 'relevance', label: 'Relevance', icon: null),
                (value: 'newest', label: 'Newest', icon: null),
              ],
              selected: settings.defaultSort,
              onSelected: vm.setDefaultSort,
            ),
          ],
        ),
      ],
    );
  }

  // ─── NOTIFICATIONS ──────────────────────────────────────────────────

  Widget _buildNotificationsSection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
    bool isLoggedIn,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: AppIcons.notifications,
          label: 'NOTIFICATIONS',
        ),
        _SettingsCard(
          children: [
            _ToggleRow(
              title: 'Replies to my comments',
              subtitle: isLoggedIn ? null : 'Requires sign-in.',
              value: settings.notifyReplies,
              onChanged: isLoggedIn ? vm.setNotifyReplies : null,
              ember: ember,
            ),
            const Divider(height: 0),
            _ToggleRow(
              title: 'Mentions',
              subtitle: 'When someone @-mentions you.',
              value: settings.notifyMentions,
              onChanged: isLoggedIn ? vm.setNotifyMentions : null,
              ember: ember,
            ),
          ],
        ),
      ],
    );
  }

  // ─── PRIVACY ────────────────────────────────────────────────────────

  Widget _buildPrivacySection(
    SettingsState settings,
    SettingsViewModel vm,
    EmberThemeExtension? ember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.shield, label: 'PRIVACY'),
        _SettingsCard(
          children: [
            _ToggleRow(
              title: 'Opt out of anonymous analytics',
              value: settings.optOutAnalytics,
              onChanged: vm.setOptOutAnalytics,
              ember: ember,
            ),
          ],
        ),
      ],
    );
  }

  // ─── DATA ───────────────────────────────────────────────────────────

  Widget _buildDataSection(SettingsViewModel vm, EmberThemeExtension? ember) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.storage, label: 'DATA'),
        _SettingsCard(
          children: [
            _TappableRow(
              title: 'Clear read history',
              onTap: () async {
                await vm.clearReadHistory();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Read history cleared')),
                );
              },
            ),
            const Divider(height: 0),
            _TappableRow(
              title: 'Clear cached stories',
              onTap: () async {
                await vm.clearCachedStories();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cached stories cleared')),
                );
              },
            ),
            const Divider(height: 0),
            _TappableRow(
              title: 'Reset all settings',
              textColor: Theme.of(context).colorScheme.error,
              trailing: Icon(
                AppIcons.reset,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset all settings?'),
                    content: const Text(
                      'This will restore all settings to their defaults. Your account will remain signed in.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await vm.resetAllSettings();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset to defaults')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // ─── ABOUT ──────────────────────────────────────────────────────────

  Widget _buildAboutSection(EmberThemeExtension? ember) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: AppIcons.info, label: 'ABOUT'),
        _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Version',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ember?.metadataColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            _TappableRow(
              title: 'Hacker News API',
              trailing: Icon(
                AppIcons.openExternal,
                size: 18,
                color: ember?.metadataColor,
              ),
              onTap: () => _launchUrl('https://github.com/HackerNews/API'),
            ),
            const Divider(height: 0),
            _TappableRow(
              title: 'Source code',
              trailing: Icon(
                AppIcons.openExternal,
                size: 18,
                color: ember?.metadataColor,
              ),
              onTap: () => _launchUrl(
                'https://github.com',
              ),
            ),
            const Divider(height: 0),
            _TappableRow(
              title: 'Send feedback',
              trailing: Icon(
                AppIcons.openExternal,
                size: 18,
                color: ember?.metadataColor,
              ),
              onTap: () => _launchUrl(
                'mailto:feedback@ember-hn.app',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── HELPER WIDGETS ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ember?.accentOrange),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ember?.accentOrange,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: ember?.storyCardBackground,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EmberThemeExtension? ember;

  const _ToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ember?.metadataColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ember?.accentOrange,
          ),
        ],
      ),
    );
  }
}

typedef _ChipOption = ({String value, String label, IconData? icon});

class _ChipRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<_ChipOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChipRow({
    required this.title,
    this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ember?.metadataColor,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (opt) => EmberChip(
                    label: opt.label,
                    icon: opt.icon,
                    selected: selected == opt.value,
                    onTap: () => onSelected(opt.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String title;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final EmberThemeExtension? ember;

  const _SliderRow({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ember?.metadataColor,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: ember?.accentOrange,
              thumbColor: ember?.accentOrange,
              inactiveTrackColor:
                  ember?.metadataColor.withAlpha(40),
              overlayColor: ember?.accentOrange.withAlpha(30),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableRow extends StatelessWidget {
  final String title;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _TappableRow({
    required this.title,
    this.textColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
