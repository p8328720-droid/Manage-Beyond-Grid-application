import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/widgets/brand_widgets.dart';
import 'package:flutter_application_1/widgets/mbg_text_field.dart';
import 'package:flutter_application_1/screens/admin/admin_home_screen.dart';
import 'package:flutter_application_1/screens/teknisi/teknisi_home_screen.dart';
import 'package:flutter_application_1/screens/user/user_home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.instance.consumePasswordResetSuccess()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui. Silakan login.'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      _goToRoleHome(user);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await AuthService.instance.loginWithGoogle();
      if (!mounted) return;
      _goToRoleHome(user);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await AuthService.instance.loginWithApple();
      if (!mounted) return;
      _goToRoleHome(user);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  void _goToRoleHome(AppUser user) {
    final routeName = switch (user.role) {
      UserRole.administrator => AdminHomeScreen.routeName,
      UserRole.pengguna => UserHomeScreen.routeName,
      UserRole.teknisi => TeknisiHomeScreen.routeName,
    };
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BrandLockup(),
                const SizedBox(height: 32),
                Text(
                  'LOG IN',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 28),
                MbgTextField(
                  controller: _emailController,
                  label: 'Email',
                  showIcon: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi.';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                MbgTextField(
                  controller: _passwordController,
                  label: 'Password',
                  showIcon: false,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _InlineLinkText(
                  prefix: 'IF YOU FORGET YOUR PASSWORD ',
                  linkLabel: 'HERE',
                  onTapLink: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleLogin,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.textPrimary),
                          ),
                        )
                      : const Text('LOGIN'),
                ),
                const SizedBox(height: 22),
                const OrDivider(),
                const SizedBox(height: 20),
                SocialSignInButton(
                  icon: const GoogleGlyph(),
                  label: 'Sign Up with Google',
                  isLoading: _isGoogleLoading,
                  onPressed: _handleGoogleLogin,
                ),
                const SizedBox(height: 12),
                SocialSignInButton(
                  icon: const Icon(Icons.apple, size: 20, color: Colors.black),
                  label: 'Sign Up with Apple',
                  isLoading: _isAppleLoading,
                  onPressed: _handleAppleLogin,
                ),
                const SizedBox(height: 28),
                Center(
                  child: _InlineLinkText(
                    prefix: 'IF YOU DONT HAVE ACCOUNT REGISTER ',
                    linkLabel: 'HERE',
                    onTapLink: () {
                      Navigator.of(context).pushNamed(RegisterScreen.routeName);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _DemoAccountsHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineLinkText extends StatelessWidget {
  final String prefix;
  final String linkLabel;
  final VoidCallback onTapLink;

  const _InlineLinkText({
    required this.prefix,
    required this.linkLabel,
    required this.onTapLink,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: linkLabel,
            style: const TextStyle(color: AppColors.accentDim),
            recognizer: TapGestureRecognizer()..onTap = onTapLink,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountsHint extends StatelessWidget {
  const _DemoAccountsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: AppTheme.monoFontFamily,
          fontSize: 11.5,
          color: AppColors.textMuted,
          height: 1.6,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// DEMO ACCOUNTS', style: TextStyle(color: AppColors.textSecondary)),
            Text('admin@mbg.io     / admin123'),
            Text('user@mbg.io      / user123'),
            Text('teknisi@mbg.io   / teknisi123'),
          ],
        ),
      ),
    );
  }
}