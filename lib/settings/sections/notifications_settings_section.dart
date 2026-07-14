import 'package:flutter/material.dart';

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
  void didUpdateWidget(
    covariant NotificationsSettingsSection oldWidget,
  ) {
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
            'Уведомления',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          title: const Text(
            'Показывать уведомление об обновлении',
          ),
          subtitle: const Text(
            'Если выключено, красная точка на иконке профиля '
            'не будет появляться.',
          ),
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