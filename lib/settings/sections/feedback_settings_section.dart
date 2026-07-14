import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum FeedbackType { bug, improvement, other }

class FeedbackSettingsSection extends StatefulWidget {
  const FeedbackSettingsSection({super.key});

  @override
  State<FeedbackSettingsSection> createState() =>
      _FeedbackSettingsSectionState();
}

class _FeedbackSettingsSectionState extends State<FeedbackSettingsSection> {
  final TextEditingController _messageController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.bug;

  bool _sending = false;
  String _technicalInfo = 'Загрузка...';

  @override
  void initState() {
    super.initState();
    _loadTechnicalInfo();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _feedbackTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Баг';
      case FeedbackType.improvement:
        return 'Предложение';
      case FeedbackType.other:
        return 'Другое';
    }
  }

  Future<void> _loadTechnicalInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final info =
          '''
Приложение: ${packageInfo.appName}
Версия: ${packageInfo.version}+${packageInfo.buildNumber}
Платформа: ${kIsWeb ? 'Web' : defaultTargetPlatform.name}
'''
              .trim();

      if (!mounted) return;

      setState(() {
        _technicalInfo = info;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _technicalInfo = 'Не удалось получить информацию';
      });
    }
  }

  Future<void> _copyTechnicalInfo() async {
    await Clipboard.setData(ClipboardData(text: _technicalInfo));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скопировано')),
    );
  }

  Future<void> _sendFeedback() async {
    final message = _messageController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (message.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Опиши проблему или предложение хотя бы в 10 символах'),
        ),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для отправки обращения нужно войти в аккаунт'),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final profileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final profile = profileSnapshot.data();

      await FirebaseFirestore.instance.collection('feedback').add({
        'uid': user.uid,
        'watcherId': profile?['accountNumber'],
        'username': profile?['username'],
        'displayName': profile?['displayName'] ?? user.displayName,
        'email': profile?['email'] ?? user.email,
        'type': _selectedType.name,
        'typeLabel': _feedbackTypeLabel(_selectedType),
        'message': message,
        'technicalInfo': _technicalInfo,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _messageController.clear();

      setState(() {
        _selectedType = FeedbackType.bug;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сообщение отправлено. Спасибо!')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('FEEDBACK FIREBASE ERROR: ${e.code} ${e.message}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Нет разрешения на отправку. Сообщи по почте о проблеме.'
                : 'Не удалось отправить сообщение',
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('FEEDBACK ERROR: $e');
      debugPrint('$stack');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось отправить сообщение')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Обратная связь',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Расскажи об ошибке или предложи улучшение для Watcher.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        DropdownButtonFormField<FeedbackType>(
          initialValue: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Тип обращения',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final type in FeedbackType.values)
              DropdownMenuItem(
                value: type,
                child: Text(_feedbackTypeLabel(type)),
              ),
          ],
          onChanged: _sending
              ? null
              : (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedType = value;
                  });
                },
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _messageController,
          enabled: !_sending,
          minLines: 6,
          maxLines: 12,
          maxLength: 2000,
          decoration: const InputDecoration(
            labelText: 'Описание',
            hintText:
                'Что произошло, чего ты ожидал(а) и как это можно повторить?',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 8),

        FilledButton.icon(
          onPressed: _sending ? null : _sendFeedback,
          icon: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: Text(_sending ? 'Открываю отправку...' : 'Отправить'),
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Text(
                'Техническая информация',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Копировать',
              onPressed: _copyTechnicalInfo,
              icon: const Icon(Icons.copy_outlined),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(14),
          ),
          child: SelectableText(_technicalInfo),
        ),
      ],
    );
  }
}
