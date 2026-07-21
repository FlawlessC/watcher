import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/copyable_setting_tile.dart';
import '../widgets/editable_setting_tile.dart';
import '../widgets/setting_tile.dart';
import '../widgets/settings_group.dart';
import '../../l10n/l10n_extension.dart';

class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  final User? user = FirebaseAuth.instance.currentUser;

  String _providerLabel(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'email':
        return 'Email';
      case 'anonymous':
        return context.l10n.accountGuest;
      default:
        return context.l10n.accountUnknownProvider;
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.accountSignOutQuestion),
        content: Text(context.l10n.accountSignOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.accountSignOut),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
  }

  Future<void> _confirmDeleteAccount() async {
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.accountDeleteQuestion),
        content: Text(context.l10n.accountDeleteExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.accountDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final deletionScheduledAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 14)),
    );

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'status': 'deleted',
      'deletionRequestedAt': FieldValue.serverTimestamp(),
      'deletionScheduledAt': deletionScheduledAt,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseAuth.instance.signOut();
  }

  Future<void> _saveNickname(String value) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'displayName': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user!.updateDisplayName(value);
  }

  Future<void> _saveEmail(String value) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'email': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Смену email в Firebase Auth добавим отдельным шагом.
  }

  void _showComingSoon(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildProfileHeader({
    required String nickname,
    required String username,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 34)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            nickname,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(indent: 24, endIndent: 24),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        const SizedBox(height: 28),
        const Divider(indent: 24, endIndent: 24),
        const SizedBox(height: 24),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: Text(context.l10n.accountSignOut),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmDeleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: Text(
                  context.l10n.accountDeleteAccount,
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(context.l10n.accountUserNotFound)),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(context.l10n.accountLoadFailed('${snapshot.error}')),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data?.data();

        final nickname =
            profile?['displayName']?.toString() ?? context.l10n.accountUnnamed;
        final watcherId = profile?['accountNumber']?.toString() ?? '—';
        final username = profile?['username']?.toString() ?? '—';
        final email = profile?['email']?.toString() ?? '—';
        final provider = profile?['provider']?.toString() ?? 'unknown';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(nickname: nickname, username: username),

            SettingsGroup(
              title: context.l10n.accountMainInformation,
              children: [
                CopyableSettingTile(
                  title: context.l10n.accountWatcherId,
                  value: watcherId,
                  copyMessage: context.l10n.accountWatcherIdCopied,
                ),
                CopyableSettingTile(
                  title: context.l10n.accountLogin,
                  value: '@$username',
                  copyMessage: context.l10n.accountLoginCopied,
                ),
              ],
            ),

            SettingsGroup(
              title: context.l10n.accountPersonalData,
              children: [
                EditableSettingTile(
                  title: context.l10n.accountNickname,
                  value: nickname,
                  confirmTitle: context.l10n.accountChangeNicknameQuestion,
                  confirmText: context.l10n.accountChangeNicknameExplanation,
                  onSave: _saveNickname,
                ),
                EditableSettingTile(
                  title: context.l10n.authEmail,
                  value: email,
                  keyboardType: TextInputType.emailAddress,
                  confirmTitle: context.l10n.accountChangeEmailQuestion,
                  confirmText: context.l10n.accountChangeEmailExplanation,
                  onSave: _saveEmail,
                ),
              ],
            ),

            SettingsGroup(
              title: context.l10n.accountSecurity,
              children: [
                SettingTile(
                  title: context.l10n.accountPassword,
                  value: provider == 'email'
                      ? context.l10n.accountChangePassword
                      : context.l10n.accountPasswordEmailOnly,
                  onTap: provider == 'email'
                      ? () => _showComingSoon(
                          context.l10n.accountPasswordComingSoon,
                        )
                      : null,
                ),
                SettingTile(
                  title: context.l10n.accountActiveDevices,
                  value: context.l10n.accountComingSoon,
                  onTap: () => _showComingSoon(
                    context.l10n.accountActiveDevicesComingSoon,
                  ),
                ),
                SettingTile(
                  title: context.l10n.accountTwoFactorProtection,
                  value: context.l10n.accountComingSoon,
                  onTap: () =>
                      _showComingSoon(context.l10n.accountTwoFactorComingSoon),
                ),
              ],
            ),

            SettingsGroup(
              title: context.l10n.accountAuthorization,
              children: [
                SettingTile(
                  title: context.l10n.accountSignInType,
                  value: _providerLabel(provider),
                ),
                if (provider == 'email' || provider == 'anonymous')
                  SettingTile(
                    title: 'Google',
                    value: context.l10n.accountLinkGoogle,
                    onTap: () => _showComingSoon(
                      context.l10n.accountLinkGoogleComingSoon,
                    ),
                  ),
                if (provider == 'anonymous')
                  SettingTile(
                    title: context.l10n.authEmail,
                    value: context.l10n.accountLinkEmail,
                    onTap: () => _showComingSoon(
                      context.l10n.accountLinkEmailComingSoon,
                    ),
                  ),
              ],
            ),

            _buildAccountActions(),
          ],
        );
      },
    );
  }
}
