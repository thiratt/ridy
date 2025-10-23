import 'package:app/pages/auth/signup/rider/page.dart';
import 'package:app/pages/auth/signup/user/page.dart';
import 'package:app/utils/navigation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/button.dart';

class SignupSelection extends StatefulWidget {
  const SignupSelection({super.key});

  @override
  State<SignupSelection> createState() => _SignupSelectionState();
}

class _SignupSelectionState extends State<SignupSelection> {
  static const String _titleText = 'คุณเป็น..?';
  static const String _userButtonText = 'ผู้ใช้งานทั่วไป';
  static const String _riderButtonText = 'ไรเดอร์';
  static const String _loginPromptText = 'มีบัญชีอยู่แล้ว? ';
  static const String _loginLinkText = 'เข้าสู่ระบบเลย';

  Future<void> _navigateToUserSignup() async {
    try {
      navigateTo(context, const UserSignupPage(), "/auth/signup/user");
    } catch (e) {
      if (mounted) {
        _showNavigationError('เกิดข้อผิดพลาดในการเปิดหน้าสมัครสมาชิกผู้ใช้งาน');
      }
    }
  }

  Future<void> _navigateToRiderSignup() async {
    try {
      navigateTo(context, const RiderSignupPage(), "/auth/signup/rider");
    } catch (e) {
      if (mounted) {
        _showNavigationError('เกิดข้อผิดพลาดในการเปิดหน้าสมัครสมาชิกไรเดอร์');
      }
    }
  }

  void _navigateToLogin() {
    try {
      Navigator.pop(context);
    } catch (e) {
      _showNavigationError('เกิดข้อผิดพลาดในการกลับไปหน้าเข้าสู่ระบบ');
    }
  }

  void _showNavigationError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'ปิด',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    _buildTitle(theme),

                    const SizedBox(height: 28),

                    _buildRoleButtons(),
                  ],
                ),
              ),
            ),

            _buildLoginLink(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          _titleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButtons() {
    return Column(
      spacing: 8,
      children: [
        PrimaryButton(
          text: _userButtonText,
          onPressed: () => _navigateToUserSignup(),
        ),

        PrimaryButton(
          text: _riderButtonText,
          onPressed: () => _navigateToRiderSignup(),
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text.rich(
        TextSpan(
          text: _loginPromptText,
          children: [
            TextSpan(
              text: _loginLinkText,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()..onTap = _navigateToLogin,
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
