import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widgets/copyable_setting_tile.dart';
import 'widgets/editable_setting_tile.dart';
import 'widgets/setting_tile.dart';
import 'widgets/settings_group.dart';

enum AccountSection { general, profile, security, auth }

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    this.initialSection = AccountSection.general,
  });

  final AccountSection initialSection;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  late AccountSection selectedSection;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.initialSection;
  }

  String _sectionTitle(AccountSection section) {
    switch (section) {
      case AccountSection.general:
        return 'Основная информация';
      case AccountSection.profile:
        return 'Личные данные';
      case AccountSection.security:
        return 'Безопасность';
      case AccountSection.auth:
        return 'Авторизация';
    }
  }

  IconData _sectionIcon(AccountSection section) {
    switch (section) {
      case AccountSection.general:
        return Icons.badge_outlined;
      case AccountSection.profile:
        return Icons.person_outline;
      case AccountSection.security:
        return Icons.security_outlined;
      case AccountSection.auth:
        return Icons.login_outlined;
    }
  }

  String _providerLabel(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'email':
        return 'Email';
      case 'anonymous':
        return 'Гость';
      default:
        return 'Неизвестно';
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти?'),
        content: const Text('Вы действительно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _confirmDeleteAccount() async {
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
          'Аккаунт будет отключён сразу, но окончательно удалится только через 14 дней.\n\n'
          'До этого момента его можно будет восстановить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
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

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Аккаунт запланирован к удалению')),
    );
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

    // Firebase Auth email перепривяжем отдельным шагом.
  }

  void _showComingSoon(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildProfileHeader({
    required BuildContext context,
    required String nickname,
    required String username,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: user!.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user!.photoURL == null
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

  Widget _buildSectionNavigation({required bool wide}) {
    final sections = AccountSection.values;

    return Material(
      color: Colors.transparent,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 12 : 0,
          vertical: wide ? 12 : 0,
        ),
        children: [
          for (final section in sections)
            ListTile(
              selected: selectedSection == section,
              leading: Icon(_sectionIcon(section)),
              title: Text(_sectionTitle(section)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () {
                setState(() => selectedSection = section);
                if (!wide) Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedSection({
    required String watcherId,
    required String username,
    required String nickname,
    required String email,
    required String provider,
  }) {
    switch (selectedSection) {
      case AccountSection.general:
        return SettingsGroup(
          title: 'Основная информация',
          children: [
            CopyableSettingTile(
              title: 'Watcher ID',
              value: watcherId,
              copyMessage: 'Watcher ID скопирован',
            ),
            CopyableSettingTile(
              title: 'Логин',
              value: '@$username',
              copyMessage: 'Логин скопирован',
            ),
          ],
        );

      case AccountSection.profile:
        return SettingsGroup(
          title: 'Личные данные',
          children: [
            EditableSettingTile(
              title: 'Ник',
              value: nickname,
              confirmTitle: 'Изменить ник?',
              confirmText: 'Новый ник будет отображаться в приложении.',
              onSave: _saveNickname,
            ),
            EditableSettingTile(
              title: 'Email',
              value: email,
              keyboardType: TextInputType.emailAddress,
              confirmTitle: 'Изменить email?',
              confirmText:
                  'Почта будет изменена в профиле. Перепривязку Firebase Auth добавим отдельным шагом.',
              onSave: _saveEmail,
            ),
          ],
        );

      case AccountSection.security:
        return SettingsGroup(
          title: 'Безопасность',
          children: [
            SettingTile(
              title: 'Пароль',
              value: provider == 'email'
                  ? 'Изменить пароль'
                  : 'Доступно для email-аккаунтов',
              onTap: provider == 'email'
                  ? () => _showComingSoon('Смену пароля добавим позже')
                  : null,
            ),
            SettingTile(
              title: 'Активные устройства',
              value: 'Появится позже',
              onTap: () => _showComingSoon('Активные устройства добавим позже'),
            ),
            SettingTile(
              title: 'Двухфакторная защита',
              value: 'Появится позже',
              onTap: () => _showComingSoon('2FA добавим позже'),
            ),
          ],
        );

      case AccountSection.auth:
        return SettingsGroup(
          title: 'Авторизация',
          children: [
            SettingTile(title: 'Тип входа', value: _providerLabel(provider)),
            if (provider == 'email' || provider == 'anonymous')
              SettingTile(
                title: 'Google',
                value: 'Привязать Google',
                onTap: () => _showComingSoon('Привязку Google добавим позже'),
              ),
            if (provider == 'anonymous')
              SettingTile(
                title: 'Email',
                value: 'Привязать Email',
                onTap: () => _showComingSoon('Привязку Email добавим позже'),
              ),
          ],
        );
    }
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
                label: const Text('Выйти'),
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
                label: const Text(
                  'Удалить аккаунт',
                  style: TextStyle(color: Colors.red),
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
      return Scaffold(
        appBar: AppBar(title: const Text('Аккаунт')),
        body: const Center(child: Text('Пользователь не найден')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final profile = snapshot.data?.data();

        final nickname = profile?['displayName']?.toString() ?? 'Без имени';
        final watcherId = profile?['accountNumber']?.toString() ?? '—';
        final username = profile?['username']?.toString() ?? '—';
        final email = profile?['email']?.toString() ?? '—';
        final provider = profile?['provider']?.toString() ?? 'unknown';

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 840;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Аккаунт'),
                actions: [
                  if (!wide)
                    PopupMenuButton<AccountSection>(
                      tooltip: 'Разделы аккаунта',
                      icon: const Icon(Icons.menu),
                      onSelected: (section) {
                        setState(() => selectedSection = section);
                      },
                      itemBuilder: (context) => [
                        for (final section in AccountSection.values)
                          PopupMenuItem(
                            value: section,
                            child: Row(
                              children: [
                                Icon(_sectionIcon(section), size: 18),
                                const SizedBox(width: 12),
                                Text(_sectionTitle(section)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 260,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: _buildSectionNavigation(wide: true),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                children: [
                                  _buildProfileHeader(
                                    context: context,
                                    nickname: nickname,
                                    username: username,
                                  ),
                                  _buildSelectedSection(
                                    watcherId: watcherId,
                                    username: username,
                                    nickname: nickname,
                                    email: email,
                                    provider: provider,
                                  ),
                                  _buildAccountActions(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          children: [
                            _buildProfileHeader(
                              context: context,
                              nickname: nickname,
                              username: username,
                            ),
                            _buildSelectedSection(
                              watcherId: watcherId,
                              username: username,
                              nickname: nickname,
                              email: email,
                              provider: provider,
                            ),
                            _buildAccountActions(),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
