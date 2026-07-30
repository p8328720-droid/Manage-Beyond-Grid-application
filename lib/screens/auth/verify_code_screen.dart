import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../widgets/brand_widgets.dart';
import '../../../../../widgets/mbg_text_field.dart';
import 'change_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  static const routeName = '/verify-code';

  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isSubmitting = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.verifyResetCode(
        code: _codeController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(email: widget.email),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    try {
      await AuthService.instance.requestPasswordReset(email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode verifikasi terkirim ulang.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BrandLockup(),
                const SizedBox(height: 28),
                Text(
                  'VERIFY CODE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 21,
                      ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'An authentication code has been sent to your email',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                MbgTextField(
                  controller: _codeController,
                  label: 'Enter Code',
                  showIcon: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kode wajib diisi.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    children: [
                      const TextSpan(text: "Didn't receive a code? "),
                      TextSpan(
                        text: _isResending ? 'Sending...' : 'Resend',
                        style: const TextStyle(
                          color: AppColors.link,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _isResending ? null : _handleResend,
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 14),
                _DemoCodeHint(),
                const Expanded(child: SizedBox()),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleVerify,
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
                      : const Text('VERIFY'),
                ),
              ],
            ),
          ),
        ),
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

class _DemoCodeHint extends StatelessWidget {
  const _DemoCodeHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'DEMO CODE: 123456',
        style: TextStyle(
          fontFamily: AppTheme.monoFontFamily,
          fontSize: 11.5,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}