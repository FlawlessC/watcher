import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/l10n_extension.dart';

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
      return context.l10n.logsEmpty;
    }

    return widget.appLogs.join('\n');
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _logsText));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.logsCopied)));
  }

  Future<void> _shareLogs() async {
    if (widget.appLogs.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        subject: context.l10n.logsShareSubject,
        text:
            '''
${context.l10n.logsShareHeader}

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
        title: Text(context.l10n.logsClearQuestion),
        content: Text(context.l10n.logsClearExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.logsClear),
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
    ).showSnackBar(SnackBar(content: Text(context.l10n.logsCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final hasLogs = widget.appLogs.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.logs,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.logsDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.logsCollect),
          subtitle: Text(context.l10n.logsCollectDescription),
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
                context.l10n.logsCollected,
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
              label: Text(context.l10n.logsShare),
            ),
            OutlinedButton.icon(
              onPressed: hasLogs ? _copyLogs : null,
              icon: const Icon(Icons.copy_outlined),
              label: Text(context.l10n.settingCopy),
            ),
            OutlinedButton.icon(
              onPressed: hasLogs ? _confirmClearLogs : null,
              icon: const Icon(Icons.delete_outline),
              label: Text(context.l10n.logsClear),
            ),
          ],
        ),
      ],
    );
  }
}
