import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_globals.dart';
import 'auth_service.dart';
import 'auth_view_mode.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/login_button.dart';
import '../l10n/l10n_extension.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthViewMode authMode = AuthViewMode.main;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool loading = false;
  String? loadingAction;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      loading = true;
      loadingAction = 'google';
    });

    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e, stack) {
      debugPrint('GOOGLE SIGN IN ERROR: $e');
      debugPrint('$stack');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.authGoogleSignInFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          loadingAction = null;
        });
      }
    }
  }

  Future<void> _submitEmailAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final repeatPassword = repeatPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack(context.l10n.authEnterEmailAndPassword);
      return;
    }

    if (authMode == AuthViewMode.emailRegister && password != repeatPassword) {
      _showSnack(context.l10n.authPasswordsDoNotMatch);
      return;
    }

    setState(() => loading = true);

    try {
      if (authMode == AuthViewMode.emailRegister) {
        await AuthService.instance.registerWithEmail(
          email: email,
          password: password,
        );
      } else {
        await AuthService.instance.signInWithEmail(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showSnack(_authErrorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnack(context.l10n.authEnterEmail);
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.instance.sendPasswordResetEmail(email);

      if (!mounted) return;

      _showSnack(context.l10n.authPasswordResetEmailSent);
      _openEmailLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showSnack(e.message ?? context.l10n.authEmailSendFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() {
      loading = true;
      loadingAction = 'guest';
    });

    try {
      await AuthService.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showSnack(e.message ?? context.l10n.authGuestSignInFailed);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _openEmailLogin() {
    setState(() {
      authMode = AuthViewMode.emailLogin;
      loading = false;
      loadingAction = null;
      obscurePassword = true;
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _openEmailRegister() {
    setState(() {
      authMode = AuthViewMode.emailRegister;
      loading = false;
      loadingAction = null;
      obscurePassword = true;
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _openPasswordReset() {
    setState(() {
      authMode = AuthViewMode.passwordReset;
      loading = false;
      loadingAction = null;
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _backToMain() {
    setState(() {
      authMode = AuthViewMode.main;
      loading = false;
      loadingAction = null;
      obscurePassword = true;
      emailController.clear();
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  Future<void> _showLanguageDialog() async {
    final currentLanguageCode = localeController.selectedLanguageCode;

    final selectedLanguageCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var temporaryLanguageCode = currentLanguageCode;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.language),
              content: RadioGroup<String>(
                groupValue: temporaryLanguageCode,
                onChanged: (value) {
                  if (value == null) return;

                  setDialogState(() {
                    temporaryLanguageCode = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'system',
                      title: Text(context.l10n.languageSystem),
                    ),
                    RadioListTile<String>(
                      value: 'ru',
                      title: Text(context.l10n.languageRussian),
                    ),
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(context.l10n.languageEnglish),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, temporaryLanguageCode);
                  },
                  child: Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedLanguageCode == null) return;

    await localeController.setLanguageCode(selectedLanguageCode);
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _authErrorMessage(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      return context.l10n.authEmailAlreadyInUse;
    }

    if (e.code == 'invalid-email') {
      return context.l10n.authInvalidEmail;
    }

    if (e.code == 'weak-password') {
      return context.l10n.authWeakPassword;
    }

    if (e.code == 'user-not-found') {
      return context.l10n.authUserNotFound;
    }

    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      return context.l10n.authWrongEmailOrPassword;
    }

    return context.l10n.authSignInFailed;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isWide
                ? 'assets/login_bg_desktop.png'
                : 'assets/login_bg_mobile.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.25)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 2400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 70 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Center(
              child: Transform.translate(
                offset: Offset(0, isWide ? -45 : 25),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AuthHeader(isWide: isWide),
                        const SizedBox(height: 34),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _buildAuthContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton.filledTonal(
                  tooltip: context.l10n.language,
                  onPressed: loading ? null : _showLanguageDialog,
                  icon: const Icon(Icons.language),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthContent() {
    switch (authMode) {
      case AuthViewMode.main:
        return _buildMainMenu();
      case AuthViewMode.emailLogin:
        return _buildEmailForm(isRegister: false);
      case AuthViewMode.emailRegister:
        return _buildEmailForm(isRegister: true);
      case AuthViewMode.passwordReset:
        return _buildPasswordResetForm();
    }
  }

  Widget _buildMainMenu() {
    final isLoading = loadingAction != null;

    return Column(
      key: const ValueKey('main-menu'),
      children: [
        LoginButton(
          icon: Icons.g_mobiledata,
          text: loadingAction == 'google'
              ? context.l10n.authWait
              : context.l10n.authSignInWithGoogle,
          onPressed: isLoading ? null : _signInWithGoogle,
        ),
        const SizedBox(height: 12),
        LoginButton(
          icon: Icons.mail_outline,
          text: context.l10n.authSignInWithEmail,
          onPressed: isLoading ? null : _openEmailLogin,
        ),
        const SizedBox(height: 12),
        LoginButton(
          icon: Icons.person_outline,
          text: loadingAction == 'guest'
              ? context.l10n.authWait
              : context.l10n.authContinueAsGuest,
          onPressed: isLoading ? null : _signInAsGuest,
        ),
      ],
    );
  }

  Widget _buildEmailForm({required bool isRegister}) {
    return Column(
      key: ValueKey(isRegister ? 'email-register' : 'email-login'),
      children: [
        AuthTextField(
          controller: emailController,
          label: context.l10n.authEmail,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: passwordController,
          label: context.l10n.authPassword,
          icon: Icons.lock_outline,
          obscureText: obscurePassword,
          suffix: _passwordVisibilityButton(),
        ),
        if (isRegister) ...[
          const SizedBox(height: 12),
          AuthTextField(
            controller: repeatPasswordController,
            label: context.l10n.authRepeatPassword,
            icon: Icons.lock_reset_outlined,
            obscureText: obscurePassword,
          ),
        ],
        const SizedBox(height: 18),
        LoginButton(
          icon: isRegister ? Icons.person_add_alt_1 : Icons.login,
          text: loading
              ? context.l10n.authWait
              : isRegister
              ? context.l10n.authCreateAccount
              : context.l10n.authSignIn,
          onPressed: loading ? null : _submitEmailAuth,
        ),
        if (!isRegister)
          TextButton(
            onPressed: loading ? null : _openPasswordReset,
            child: Text(
              context.l10n.authForgotPassword,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: loading
              ? null
              : isRegister
              ? _openEmailLogin
              : _openEmailRegister,
          child: Text(
            isRegister
                ? context.l10n.authAlreadyHaveAccount
                : context.l10n.authCreateAccount,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        TextButton.icon(
          onPressed: loading ? null : _backToMain,
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          label: Text(
            context.l10n.back,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordResetForm() {
    return Column(
      key: const ValueKey('password-reset'),
      children: [
        AuthTextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          label: context.l10n.authRecoveryEmail,
          icon: Icons.mail_outline,
        ),
        const SizedBox(height: 18),
        LoginButton(
          icon: Icons.mark_email_read_outlined,
          text: loading ? context.l10n.authSending : context.l10n.authSendEmail,
          onPressed: loading ? null : _sendPasswordResetEmail,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: loading ? null : _openEmailLogin,
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          label: Text(
            context.l10n.authBackToSignIn,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _passwordVisibilityButton() {
    return IconButton(
      icon: Icon(
        obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: Colors.white70,
      ),
      onPressed: () {
        setState(() => obscurePassword = !obscurePassword);
      },
    );
  }
}
