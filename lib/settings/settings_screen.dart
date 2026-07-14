import 'package:flutter/material.dart';

import 'sections/account_settings_section.dart';
import 'sections/feedback_settings_section.dart';
import 'sections/logs_settings_section.dart';
import 'sections/notifications_settings_section.dart';

enum SettingsSection { account, notifications, logs, feedback }

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
  });

  final String initialSection;
  final bool collectLogs;
  final List<String> appLogs;
  final ValueChanged<bool> onCollectLogsChanged;
  final VoidCallback onClearLogs;
  final bool showUpdateBadge;
  final ValueChanged<bool> onShowUpdateBadgeChanged;

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
      _ => SettingsSection.account,
    };
  }

  String _sectionTitle(SettingsSection section) {
    switch (section) {
      case SettingsSection.account:
        return 'Аккаунт';
      case SettingsSection.notifications:
        return 'Уведомления';
      case SettingsSection.logs:
        return 'Логи';
      case SettingsSection.feedback:
        return 'Обратная связь';
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
            title: const Text('Назад в Watcher'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onTap: () => _closeDrawerAndGoBack(context),
          ),
          const Divider(height: 24),
        ],
        for (final section in SettingsSection.values)
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
                        tooltip: 'Открыть меню',
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(scaffoldContext).openDrawer();
                        },
                      );
                    },
                  )
                : IconButton(
                    tooltip: 'Назад',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
            title: Text(compact ? _sectionTitle(selectedSection) : 'Настройки'),
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
