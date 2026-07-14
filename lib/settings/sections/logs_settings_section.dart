import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class LogsSettingsSection extends StatefulWidget {
  const LogsSettingsSection({
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
  State<LogsSettingsSection> createState() => _LogsSettingsSectionState();
}

class _LogsSettingsSectionState extends State<LogsSettingsSection> {
  late bool collectLogs;

  @override
  void initState() {
    super.initState();
    collectLogs = widget.collectLogs;
  }

  @override
  void didUpdateWidget(covariant LogsSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.collectLogs != widget.collectLogs) {
      collectLogs = widget.collectLogs;
    }
  }

  String get _logsText {
    if (widget.appLogs.isEmpty) {
      return 'Логов пока нет';
    }

    return widget.appLogs.join('\n');
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _logsText));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Логи скопированы')));
  }

  Future<void> _shareLogs() async {
    if (widget.appLogs.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        subject: 'Watcher — логи приложения',
        text:
            '''
Watcher — логи приложения

$_logsText
''',
      ),
    );
  }

  Future<void> _confirmClearLogs() async {
    if (widget.appLogs.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить логи?'),
        content: const Text(
          'Все собранные за текущий запуск логи будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    widget.onClearLogs();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Логи очищены')));
  }

  @override
  Widget build(BuildContext context) {
    final hasLogs = widget.appLogs.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Логи',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Логи помогают найти причину ошибки в приложении.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Собирать логи'),
          subtitle: const Text(
            'Сбор выполняется только во время работы приложения.',
          ),
          value: collectLogs,
          onChanged: (value) {
            setState(() => collectLogs = value);
            widget.onCollectLogsChanged(value);
          },
        ),

        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: Text(
                'Собранные логи',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${widget.appLogs.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          constraints: const BoxConstraints(minHeight: 180, maxHeight: 420),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(14),
          ),
          child: SingleChildScrollView(child: SelectableText(_logsText)),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: hasLogs ? _shareLogs : null,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Поделиться'),
            ),
            OutlinedButton.icon(
              onPressed: hasLogs ? _copyLogs : null,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Копировать'),
            ),
            OutlinedButton.icon(
              onPressed: hasLogs ? _confirmClearLogs : null,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Очистить'),
            ),
          ],
        ),
      ],
    );
  }
}

