import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  static const String _preferenceKey = 'app_locale';

  /// null означает: использовать язык устройства.
  bool get usesSystemLocale => value == null;

  String get selectedLanguageCode => value?.languageCode ?? 'system';

  Future<void> load() async {
    final preferences = SharedPreferencesAsync();

    final savedLanguageCode = await preferences.getString(
      _preferenceKey,
    );

    if (savedLanguageCode == null ||
        savedLanguageCode.isEmpty ||
        savedLanguageCode == 'system') {
      value = null;
      return;
    }

    value = Locale(savedLanguageCode);
  }

  Future<void> useSystemLocale() async {
    value = null;

    final preferences = SharedPreferencesAsync();

    await preferences.setString(
      _preferenceKey,
      'system',
    );
  }

  Future<void> setLocale(Locale locale) async {
    value = locale;

    final preferences = SharedPreferencesAsync();

    await preferences.setString(
      _preferenceKey,
      locale.languageCode,
    );
  }

  Future<void> setLanguageCode(String languageCode) async {
    if (languageCode == 'system') {
      await useSystemLocale();
      return;
    }

    await setLocale(Locale(languageCode));
  }
}