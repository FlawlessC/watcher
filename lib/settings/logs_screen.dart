import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({
    super.key,
    required this.collectLogs,
    required this.appLogs,
    required this.onCollectLogsChanged,
    required this.onClearLogs,
  });

  final bool collectLogs;
  final List<String> appLogs;
  final ValueChanged<bool> onCollectLogsChanged;
  final VoidCallback onClearLogs;

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late bool collectLogs;

  @override
  void initState() {
    super.initState();
    collectLogs = widget.collectLogs;
  }

  @override
  Widget build(BuildContext context) {
    final logsText = widget.appLogs.isEmpty
        ? 'Логов пока нет'
        : widget.appLogs.join('\n');

    return Scaffold(
      appBar: AppBar(title: const Text('Логи')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Собирать логи'),
            value: collectLogs,
            onChanged: (value) {
              setState(() => collectLogs = value);
              widget.onCollectLogsChanged(value);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Собранные логи',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(logsText),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: logsText));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Логи скопированы')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Копировать логи'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              widget.onClearLogs();
              setState(() {});
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Очистить логи'),
          ),
        ],
      ),
    );
  }
}