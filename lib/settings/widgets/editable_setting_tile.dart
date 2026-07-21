import 'package:flutter/material.dart';
import 'setting_tile.dart';
import '../../l10n/l10n_extension.dart';

class EditableSettingTile extends StatefulWidget {
  const EditableSettingTile({
    super.key,
    required this.title,
    required this.value,
    required this.onSave,
    required this.confirmTitle,
    required this.confirmText,
    this.maxLength = 40,
    this.keyboardType,
  });

  final String title;
  final String value;
  final Future<void> Function(String value) onSave;
  final String confirmTitle;
  final String confirmText;
  final int maxLength;
  final TextInputType? keyboardType;

  @override
  State<EditableSettingTile> createState() => _EditableSettingTileState();
}

class _EditableSettingTileState extends State<EditableSettingTile> {
  late final TextEditingController _controller;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant EditableSettingTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_editing && oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newValue = _controller.text.trim();

    if (newValue == widget.value.trim()) {
      setState(() => _editing = false);
      return;
    }

    if (newValue.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingValueTooShort)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.confirmTitle),
        content: Text(widget.confirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.settingEdit),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _saving = true);

    try {
      await widget.onSave(newValue);

      if (!mounted) return;

      setState(() {
        _editing = false;
        _saving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.settingChangesSaved)));
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingSaveFailed('$e'))),
      );
    }
  }

  void _cancel() {
    _controller.text = widget.value;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              enabled: !_saving,
              maxLength: widget.maxLength,
              keyboardType: widget.keyboardType,
              decoration: const InputDecoration(
                counterText: '',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: context.l10n.cancel,
                  onPressed: _saving ? null : _cancel,
                  icon: const Icon(Icons.close),
                ),
                IconButton(
                  tooltip: context.l10n.save,
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SettingTile(
      title: widget.title,
      value: widget.value,
      trailing: IconButton(
        tooltip: context.l10n.settingEdit,
        onPressed: () => setState(() => _editing = true),
        icon: const Icon(Icons.edit),
      ),
    );
  }
}
