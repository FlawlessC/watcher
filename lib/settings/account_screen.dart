import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widgets/copyable_setting_tile.dart';
import 'widgets/editable_setting_tile.dart';
import 'widgets/setting_section.dart';
import 'widgets/setting_tile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

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

        return Scaffold(
          appBar: AppBar(title: const Text('Аккаунт')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
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
                          username,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),

                  SettingSection(
                    title: 'Основная информация',
                    children: [
                      CopyableSettingTile(
                        title: 'Watcher ID',
                        value: watcherId,
                        copyMessage: 'Watcher ID скопирован',
                      ),
                      CopyableSettingTile(
                        title: 'Логин',
                        value: username,
                        copyMessage: 'Логин скопирован',
                      ),
                    ],
                  ),

                  SettingSection(
                    title: 'Личные данные',
                    children: [
                      EditableSettingTile(
                        title: 'Ник',
                        value: nickname,
                        confirmTitle: 'Изменить ник?',
                        confirmText:
                            'Новый ник будет отображаться в приложении.',
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
                  ),

                  SettingSection(
                    title: 'Авторизация',
                    children: [
                      SettingTile(
                        title: 'Тип входа',
                        value: _providerLabel(provider),
                      ),
                      if (provider == 'email' || provider == 'anonymous')
                        SettingTile(
                          title: 'Google',
                          value: 'Привязать Google',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Привязку Google добавим позже',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
