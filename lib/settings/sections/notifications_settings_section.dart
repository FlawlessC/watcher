import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';

class NotificationsSettingsSection extends StatefulWidget {
  const NotificationsSettingsSection({
    super.key,
    required this.showUpdateBadge,
    required this.onShowUpdateBadgeChanged,
  });

  final bool showUpdateBadge;
  final ValueChanged<bool> onShowUpdateBadgeChanged;

  @override
  State<NotificationsSettingsSection> createState() =>
      _NotificationsSettingsSectionState();
}

class _NotificationsSettingsSectionState
    extends State<NotificationsSettingsSection> {
  late bool showUpdateBadge;

  @override
  void initState() {
    super.initState();
    showUpdateBadge = widget.showUpdateBadge;
  }

  @override
  void didUpdateWidget(covariant NotificationsSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showUpdateBadge != widget.showUpdateBadge) {
      showUpdateBadge = widget.showUpdateBadge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Text(
            context.l10n.notifications,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          title: Text(context.l10n.notificationsShowUpdate),
          subtitle: Text(context.l10n.notificationsShowUpdateDescription),
          value: showUpdateBadge,
          onChanged: (value) {
            setState(() => showUpdateBadge = value);
            widget.onShowUpdateBadgeChanged(value);
          },
        ),
      ],
    );
  }
}
