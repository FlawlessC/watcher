import 'package:flutter/material.dart';

class SettingSection extends StatelessWidget {
  const SettingSection({
    super.key,
    this.title,
    required this.children,
  });

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final separatedChildren = <Widget>[];

    for (var i = 0; i < children.length; i++) {
      separatedChildren.add(children[i]);

      if (i != children.length - 1) {
        separatedChildren.add(
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: separatedChildren),
        ),
      ],
    );
  }
}