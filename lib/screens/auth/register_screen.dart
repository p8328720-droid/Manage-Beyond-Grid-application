import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/system_config_service.dart';
import 'package:flutter_application_1/widgets/brand_widgets.dart';
import 'package:flutter_application_1/widgets/mbg_text_field.dart';
import 'package:flutter_application_1/screens/user/user_home_screen.dart';


class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isGithubLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!SystemConfigService.instance.allowRegistration) {
      setState(() {
        _errorMessage = 'Pendaftaran akun baru sedang ditutup oleh administrator.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      _goToUserHome();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goToUserHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      UserHomeScreen.routeName,
      (_) => false,
    );
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.instance.loginWithGoogle();
      if (!mounted) return;
      _goToUserHome();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() {
      _isAppleLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.instance.loginWithApple();
      if (!mounted) return;
      _goToUserHome();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  Future<void> _handleGithubSignUp() async {
    setState(() {
      _isGithubLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.instance.loginWithGithub();
      final user = AuthService.instance.currentUser;
      if (user != null && mounted) _goToUserHome();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isGithubLoading = false);
    }
  }

  void _notImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — belum diimplementasikan.')),
    );
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
                const SizedBox(height: 28),
                Text(
                  'SIGN UP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Looks like you don't have an account. Let's create a "
                  'new account for you.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                MbgTextField(
                  controller: _nameController,
                  label: 'Name',
                  showIcon: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
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
                    if (value.length < 6) {
                      return 'Minimal 6 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _TermsNotice(
                  onTapTerms: () => _notImplemented('Terms of Service'),
                  onTapPrivacy: () => _notImplemented('Privacy Policy'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleCreateAccount,
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
                      : const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: 22),
                const OrDivider(),
                const SizedBox(height: 20),
                SocialSignInButton(
                  icon: const GoogleGlyph(),
                  label: 'Sign Up with Google',
                  isLoading: _isGoogleLoading,
                  onPressed: _handleGoogleSignUp,
                ),
                const SizedBox(height: 12),
                SocialSignInButton(
                  icon: const Icon(Icons.apple, size: 20, color: Colors.black),
                  label: 'Sign Up with Apple',
                  isLoading: _isAppleLoading,
                  onPressed: _handleAppleSignUp,
                ),
                const SizedBox(height: 12),
                SocialSignInButton(
                  icon: const Icon(Icons.code, size: 20, color: Colors.black),
                  label: 'Sign Up with GitHub',
                  isLoading: _isGithubLoading,
                  onPressed: _handleGithubSignUp,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : _goToUserHome,
                    child: const Text(
                      'CONTINUE AS A GUEST',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
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

class _TermsNotice extends StatelessWidget {
  final VoidCallback onTapTerms;
  final VoidCallback onTapPrivacy;

  const _TermsNotice({required this.onTapTerms, required this.onTapPrivacy});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.5,
          height: 1.4,
        ),
        children: [
          const TextSpan(
            text: 'By selecting Create Account below, I agree to ',
          ),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTapTerms,
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTapPrivacy,
          ),
          const TextSpan(text: '.'),
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