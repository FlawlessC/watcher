import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';

class UpdatesSettingsSection extends StatelessWidget {
  const UpdatesSettingsSection({
    super.key,
    required this.currentVersion,
    required this.showUpdateBadge,
    required this.onShowUpdateBadgeChanged,
    required this.onCheckForUpdate,
    required this.onShowReleaseNotes,
    required this.updateAvailable,
    this.availableVersion,
  });

  final String currentVersion;

  final bool showUpdateBadge;
  final ValueChanged<bool> onShowUpdateBadgeChanged;

  final Future<void> Function() onCheckForUpdate;
  final Future<void> Function() onShowReleaseNotes;

  final bool updateAvailable;
  final String? availableVersion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.updates,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.updatesDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),

        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(context.l10n.updatesCurrentVersion),
          trailing: Text(currentVersion.isEmpty ? '—' : currentVersion),
        ),

        if (updateAvailable)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.system_update),
            title: Text(context.l10n.updatesAvailable),
            trailing: Text(
              availableVersion?.isNotEmpty == true
                  ? availableVersion!
                  : context.l10n.updatesNewVersion,
            ),
          ),

        const Divider(height: 32),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.updatesShowIndicator),
          subtitle: Text(context.l10n.updatesIndicatorDescription),
          value: showUpdateBadge,
          onChanged: onShowUpdateBadgeChanged,
        ),

        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: onCheckForUpdate,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.updatesCheck),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: onShowReleaseNotes,
          icon: const Icon(Icons.new_releases_outlined),
          label: Text(context.l10n.updatesWhatsNew),
        ),
      ],
    );
  }
}
