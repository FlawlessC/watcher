import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'locale_controller.dart';

final GoogleSignIn appGoogleSignIn = GoogleSignIn(
  clientId:
      '92396295432-28qavr9votkv53p98u6sdlhfpet9vuru.apps.googleusercontent.com',
  scopes: <String>['email', 'profile'],
);
final localeController = LocaleController();
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
