import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'auth_view_mode.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/login_button.dart';

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
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => loading = true);

    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e, stack) {
      debugPrint('GOOGLE SIGN IN ERROR: $e');
      debugPrint('$stack');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось войти через Google')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _submitEmailAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final repeatPassword = repeatPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Введите email и пароль');
      return;
    }

    if (authMode == AuthViewMode.emailRegister && password != repeatPassword) {
      _showSnack('Пароли не совпадают');
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
      _showSnack(_authErrorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnack('Введите email');
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.instance.sendPasswordResetEmail(email);

      if (!mounted) return;

      _showSnack('Письмо для сброса пароля отправлено');
      _openEmailLogin();
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Не удалось отправить письмо');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => loading = true);

    try {
      await AuthService.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Не удалось войти как гость');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _openEmailLogin() {
    setState(() {
      authMode = AuthViewMode.emailLogin;
      loading = false;
      obscurePassword = true;
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _openEmailRegister() {
    setState(() {
      authMode = AuthViewMode.emailRegister;
      loading = false;
      obscurePassword = true;
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _openPasswordReset() {
    setState(() {
      authMode = AuthViewMode.passwordReset;
      loading = false;
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _backToMain() {
    setState(() {
      authMode = AuthViewMode.main;
      loading = false;
      obscurePassword = true;
      emailController.clear();
      passwordController.clear();
      repeatPasswordController.clear();
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _authErrorMessage(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      return 'Этот email уже зарегистрирован';
    }

    if (e.code == 'invalid-email') {
      return 'Некорректный email';
    }

    if (e.code == 'weak-password') {
      return 'Пароль слишком простой';
    }

    if (e.code == 'user-not-found') {
      return 'Пользователь не найден';
    }

    if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      return 'Неверный email или пароль';
    }

    return 'Не удалось войти';
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
                offset: Offset(0, isWide ? -45 : -35),
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
    return Column(
      key: const ValueKey('main-menu'),
      children: [
        LoginButton(
          icon: Icons.g_mobiledata,
          text: loading ? 'Подождите...' : 'Войти через Google',
          onPressed: loading ? null : _signInWithGoogle,
        ),
        const SizedBox(height: 12),
        LoginButton(
          icon: Icons.mail_outline,
          text: 'Войти по email',
          onPressed: loading ? null : _openEmailLogin,
        ),
        const SizedBox(height: 12),
        LoginButton(
          icon: Icons.person_outline,
          text: loading ? 'Подождите...' : 'Продолжить как гость',
          onPressed: loading ? null : _signInAsGuest,
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
          label: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: passwordController,
          label: 'Пароль',
          icon: Icons.lock_outline,
          obscureText: obscurePassword,
          suffix: _passwordVisibilityButton(),
        ),
        if (isRegister) ...[
          const SizedBox(height: 12),
          AuthTextField(
            controller: repeatPasswordController,
            label: 'Повтор пароля',
            icon: Icons.lock_reset_outlined,
            obscureText: obscurePassword,
          ),
        ],
        const SizedBox(height: 18),
        LoginButton(
          icon: isRegister ? Icons.person_add_alt_1 : Icons.login,
          text: loading
              ? 'Подождите...'
              : isRegister
                  ? 'Создать аккаунт'
                  : 'Войти',
          onPressed: loading ? null : _submitEmailAuth,
        ),
        if (!isRegister)
          TextButton(
            onPressed: loading ? null : _openPasswordReset,
            child: const Text(
              'Забыли пароль?',
              style: TextStyle(color: Colors.white70),
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
            isRegister ? 'Уже есть аккаунт' : 'Создать аккаунт',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        TextButton.icon(
          onPressed: loading ? null : _backToMain,
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          label: const Text(
            'Назад',
            style: TextStyle(color: Colors.white70),
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
          label: 'Email для восстановления',
          icon: Icons.mail_outline,
        ),
        const SizedBox(height: 18),
        LoginButton(
          icon: Icons.mark_email_read_outlined,
          text: loading ? 'Отправляю...' : 'Отправить письмо',
          onPressed: loading ? null : _sendPasswordResetEmail,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: loading ? null : _openEmailLogin,
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          label: const Text(
            'Назад ко входу',
            style: TextStyle(color: Colors.white70),
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
