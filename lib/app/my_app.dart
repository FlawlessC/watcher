import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../auth/auth_gate.dart';
import '../core/app_globals.dart';
import '../l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentThemeMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeController,
          builder: (_, currentLocale, _) {
            return MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,
              debugShowCheckedModeBanner: false,

              locale: currentLocale,

              supportedLocales:
                  AppLocalizations.supportedLocales,

              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              themeMode: currentThemeMode,
              themeAnimationDuration:
                  const Duration(milliseconds: 450),
              themeAnimationCurve: Curves.easeInOutCubic,

              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.indigo,
              ),

              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: Colors.indigo,
              ),

              home: const AuthGate(),
            );
          },
        );
      },
    );
  }
}