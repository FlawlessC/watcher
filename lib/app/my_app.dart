import 'package:flutter/material.dart';

import '../auth/auth_gate.dart';
import '../core/app_globals.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        // Заменили __ на _
        return MaterialApp(
          title: 'Watcher',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.indigo,
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}
