import 'package:flutter/material.dart';

import '../../core/app_globals.dart';
import '../../l10n/l10n_extension.dart';

class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedLanguageCode = localeController.selectedLanguageCode;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.language,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.settingsLanguage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: RadioGroup<String>(
                    groupValue: selectedLanguageCode,
                    onChanged: (value) async {
                      if (value == null) return;

                      await localeController.setLanguageCode(value);
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'system',
                          secondary: const Icon(Icons.settings_suggest_outlined),
                          title: Text(context.l10n.languageSystem),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          value: 'ru',
                          secondary: const Icon(Icons.language),
                          title: Text(context.l10n.languageRussian),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          value: 'en',
                          secondary: const Icon(Icons.language),
                          title: Text(context.l10n.languageEnglish),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}