import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.showUpdateBadge,
    required this.onShowUpdateBadgeChanged,
  });

  final bool showUpdateBadge;
  final ValueChanged<bool> onShowUpdateBadgeChanged;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool showUpdateBadge;

  @override
  void initState() {
    super.initState();
    showUpdateBadge = widget.showUpdateBadge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Показывать уведомление об обновлении'),
            subtitle: const Text(
              'Если выключено, красная точка на иконке профиля не будет появляться.',
            ),
            value: showUpdateBadge,
            onChanged: (value) {
              setState(() => showUpdateBadge = value);
              widget.onShowUpdateBadgeChanged(value);
            },
          ),
        ],
      ),
    );
  }
}