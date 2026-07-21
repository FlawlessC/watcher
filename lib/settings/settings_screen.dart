import 'package:flutter/material.dart';
import 'sections/updates_settings_section.dart';
import 'sections/account_settings_section.dart';
import 'sections/feedback_settings_section.dart';
import 'sections/logs_settings_section.dart';
import 'sections/notifications_settings_section.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sections/language_settings_section.dart';
import '../l10n/l10n_extension.dart';

enum SettingsSection {
  account,
  language,
  notifications,
  updates,
  logs,
  feedback,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.initialSection = 'main',
    required this.collectLogs,
    required this.appLogs,
    required this.onCollectLogsChanged,
    required this.onClearLogs,
    required this.showUpdateBadge,
    required this.onShowUpdateBadgeChanged,
    required this.currentVersion,
    required this.updateAvailable,
    required this.availableVersion,
    required this.onCheckForUpdate,
    required this.onShowReleaseNotes,
  });

  final String initialSection;
  final bool collectLogs;
  final List<String> appLogs;
  final ValueChanged<bool> onCollectLogsChanged;
  final VoidCallback onClearLogs;
  final bool showUpdateBadge;
  final ValueChanged<bool> onShowUpdateBadgeChanged;
  final String currentVersion;
  final bool updateAvailable;
  final String? availableVersion;

  final Future<void> Function() onCheckForUpdate;
  final Future<void> Function() onShowReleaseNotes;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsSection selectedSection = SettingsSection.account;

  @override
  void initState() {
    super.initState();

    selectedSection = switch (widget.initialSection) {
      'notifications' => SettingsSection.notifications,
      'logs' => SettingsSection.logs,
      'feedback' => SettingsSection.feedback,
      'updates' => SettingsSection.updates,
      'language' => SettingsSection.language,
      _ => SettingsSection.account,
    };
  }

  String _sectionTitle(SettingsSection section) {
    switch (section) {
      case SettingsSection.account:
        return context.l10n.settingsAccount;
      case SettingsSection.notifications:
        return context.l10n.settingsNotifications;
      case SettingsSection.logs:
        return context.l10n.settingsLogs;
      case SettingsSection.feedback:
        return context.l10n.settingsFeedback;
      case SettingsSection.updates:
        return context.l10n.settingsUpdates;
      case SettingsSection.language:
        return context.l10n.settingsLanguage;
    }
  }

  IconData _sectionIcon(SettingsSection section) {
    switch (section) {
      case SettingsSection.account:
        return Icons.account_circle_outlined;
      case SettingsSection.notifications:
        return Icons.notifications_outlined;
      case SettingsSection.logs:
        return Icons.description_outlined;
      case SettingsSection.feedback:
        return Icons.feedback_outlined;
      case SettingsSection.updates:
        return Icons.system_update_outlined;
      case SettingsSection.language:
        return Icons.language;
    }
  }

  void _selectSection(SettingsSection section, {bool closeDrawer = false}) {
    setState(() => selectedSection = section);

    if (closeDrawer) {
      Navigator.pop(context);
    }
  }

  void _closeDrawerAndGoBack(BuildContext drawerContext) {
    Navigator.pop(drawerContext);

    Future.microtask(() {
      if (!mounted) return;
      Navigator.maybePop(context);
    });
  }

  Widget _buildNavigation({required bool compact}) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        if (compact) ...[
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: Text(context.l10n.backToWatcher),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onTap: () => _closeDrawerAndGoBack(context),
          ),
          const Divider(height: 24),
        ],
        for (final section in SettingsSection.values)
          if (!kIsWeb || section != SettingsSection.updates)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                selected: selectedSection == section,
                leading: Icon(_sectionIcon(section)),
                title: Text(_sectionTitle(section)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onTap: () => _selectSection(section, closeDrawer: compact),
              ),
            ),
      ],
    );
  }

  Widget _buildSelectedSection() {
    switch (selectedSection) {
      case SettingsSection.account:
        return SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: AccountSettingsSection(),
              ),
            ),
          ),
        );
      case SettingsSection.updates:
        return UpdatesSettingsSection(
          currentVersion: widget.currentVersion,
          showUpdateBadge: widget.showUpdateBadge,
          onShowUpdateBadgeChanged: widget.onShowUpdateBadgeChanged,
          onCheckForUpdate: widget.onCheckForUpdate,
          onShowReleaseNotes: widget.onShowReleaseNotes,
          updateAvailable: widget.updateAvailable,
          availableVersion: widget.availableVersion,
        );
      case SettingsSection.language:
        return const LanguageSettingsSection();
      case SettingsSection.notifications:
        return NotificationsSettingsSection(
          showUpdateBadge: widget.showUpdateBadge,
          onShowUpdateBadgeChanged: widget.onShowUpdateBadgeChanged,
        );

      case SettingsSection.logs:
        return LogsSettingsSection(
          collectLogs: widget.collectLogs,
          appLogs: widget.appLogs,
          onCollectLogsChanged: widget.onCollectLogsChanged,
          onClearLogs: widget.onClearLogs,
        );

      case SettingsSection.feedback:
        return const FeedbackSettingsSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 840;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: compact
                ? Builder(
                    builder: (scaffoldContext) {
                      return IconButton(
                        tooltip: context.l10n.openMenu,
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(scaffoldContext).openDrawer();
                        },
                      );
                    },
                  )
                : IconButton(
                    tooltip: context.l10n.back,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
            title: Text(
              compact ? _sectionTitle(selectedSection) : context.l10n.settings,
            ),
          ),
          drawer: compact
              ? Drawer(child: SafeArea(child: _buildNavigation(compact: true)))
              : null,
          body: compact
              ? _buildSelectedSection()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: (constraints.maxWidth * 0.22).clamp(280.0, 380.0),
                      child: _buildNavigation(compact: false),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildSelectedSection()),
                  ],
                ),
        );
      },
    );
  }
}
