import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'setting_tile.dart';

class CopyableSettingTile extends StatelessWidget {
  const CopyableSettingTile({
    super.key,
    required this.title,
    required this.value,
    this.copyMessage,
  });

  final String title;
  final String value;
  final String? copyMessage;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title,
      value: value,
      trailing: IconButton(
        tooltip: "Копировать",
        icon: const Icon(Icons.copy),
        onPressed: () async {
          await Clipboard.setData(
            ClipboardData(text: value),
          );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                copyMessage ?? "Скопировано",
              ),
            ),
          );
        },
      ),
    );
  }
}