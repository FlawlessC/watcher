import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'feedback_screen.dart';
import 'logs_screen.dart';
import 'notifications_screen.dart';

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
  bool accountExpanded = true;

  void _openAccount(AccountSection section) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AccountScreen(initialSection: section)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text('Аккаунт'),
            children: [
              ListTile(
                title: const Text('Основная информация'),
                onTap: () => _openAccount(AccountSection.general),
              ),
              ListTile(
                title: const Text('Личные данные'),
                onTap: () => _openAccount(AccountSection.profile),
              ),
              ListTile(
                title: const Text('Безопасность'),
                onTap: () => _openAccount(AccountSection.security),
              ),
              ListTile(
                title: const Text('Авторизация'),
                onTap: () => _openAccount(AccountSection.auth),
              ),
            ],
          ),

          const Divider(height: 1),

          ExpansionTile(
            title: const Text('Уведомления'),
            children: [
              ListTile(
                title: const Text('Настройки уведомлений'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(
                        showUpdateBadge: widget.showUpdateBadge,
                        onShowUpdateBadgeChanged:
                            widget.onShowUpdateBadgeChanged,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const Divider(height: 1),

          ExpansionTile(
            title: const Text('Логи'),
            children: [
              ListTile(
                title: const Text('Настройки логов'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogsScreen(
                        collectLogs: widget.collectLogs,
                        appLogs: widget.appLogs,
                        onCollectLogsChanged: widget.onCollectLogsChanged,
                        onClearLogs: widget.onClearLogs,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const Divider(height: 1),

          ExpansionTile(
            title: const Text('Обратная связь'),
            children: [
              ListTile(
                title: const Text('Открыть раздел'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
