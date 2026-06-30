import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'feedback_screen.dart';
import 'logs_screen.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
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
  final bool showUpdateBadge;
  final ValueChanged<bool> onShowUpdateBadgeChanged;
  final String initialSection;
  final bool collectLogs;
  final List<String> appLogs;
  final ValueChanged<bool> onCollectLogsChanged;
  final VoidCallback onClearLogs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Аккаунт"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            title: const Text("Уведомления"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(
                    showUpdateBadge: showUpdateBadge,
                    onShowUpdateBadgeChanged: onShowUpdateBadgeChanged,
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            title: const Text("Логи"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LogsScreen(
                    collectLogs: collectLogs,
                    appLogs: appLogs,
                    onCollectLogsChanged: onCollectLogsChanged,
                    onClearLogs: onClearLogs,
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            title: const Text("Обратная связь"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
