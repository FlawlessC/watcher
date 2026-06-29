import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_globals.dart';
import '../services/user_profile_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});

      final credential = await _firebaseAuth.signInWithPopup(provider);
      await _ensureProfile(credential.user, provider: 'google');
      return;
    }

    await appGoogleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await appGoogleSignIn.signIn();

    if (googleUser == null) {
      debugPrint('Google sign in cancelled');
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await _ensureProfile(userCredential.user, provider: 'google');
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _ensureProfile(credential.user, provider: 'email');
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final nameFromEmail = email.split('@').first;
    await credential.user?.updateDisplayName(nameFromEmail);
    await credential.user?.reload();

    await _ensureProfile(_firebaseAuth.currentUser ?? credential.user, provider: 'email');
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    await _ensureProfile(credential.user, provider: 'anonymous');
  }

  Future<void> _ensureProfile(User? user, {required String provider}) async {
    if (user == null) return;

    try {
      await UserProfileService.instance.ensureUserProfile(
        user,
        provider: provider,
      );
    } catch (e, stack) {
      debugPrint('ENSURE USER PROFILE ERROR: $e');
      debugPrint('$stack');
    }
  }
}
