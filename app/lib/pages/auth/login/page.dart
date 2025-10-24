import 'dart:developer';

import 'package:app/models/response/role_selection_response.dart';
import 'package:app/pages/auth/signup/page.dart';
import 'package:app/pages/home/rider/page.dart';
import 'package:app/services/authentication.dart';
import 'package:app/shared/provider.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/home_wrapper.dart';
import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthenticationService();

  bool _isLoading = false;
  String? _errorMessage;

  static const String _logoPath = 'assets/images/logo_black.png';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกเบอร์โทรศัพท์';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length != 10) {
      return 'เบอร์โทรศัพท์ต้องมี 10 หลัก';
    }

    if (!cleanPhone.startsWith('0')) {
      return 'เบอร์โทรศัพท์ต้องเริ่มต้นด้วย 0';
    }

    final prefix = cleanPhone.substring(0, 2);
    if (!['08', '09', '06'].contains(prefix)) {
      return 'รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }

    if (value.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _performLogin();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performLogin() async {
    final result = await _authService.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    await _handleAuthResult(result);
  }

  Future<void> _handleAuthResult(AuthLoginResponse result) async {
    final provider = Provider.of<RidyProvider>(context, listen: false);

    switch (result.result) {
      case LoginResult.success:
        if (result.user != null) {
          _authService.saveUserToProvider(provider, result.user!);
          await _navigateToHome(result.user!.role, result.user!.id);
        }
        break;

      case LoginResult.roleSelectionRequired:
        if (result.availableRoles != null) {
          await _showRoleSelectionDialog(result.availableRoles!);
        }
        break;

      case LoginResult.invalidCredentials:
        throw result.message ?? 'เบอร์โทรศัพท์หรือรหัสผ่านไม่ถูกต้อง';

      case LoginResult.serverError:
        throw result.message ?? 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง';

      case LoginResult.networkError:
        throw result.message ??
            'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง';
    }
  }

  Future<void> _navigateToHome(String role, String userId) async {
    if (!mounted) return;

    _clearErrorMessage();

    final Widget homePage = role == "USER"
        ? HomeWrapper(uid: userId)
        : RiderHomePage(uid: userId);

    await navigateReplaceTo(
      context,
      homePage,
      '/home/$role'.toLowerCase(),
      useDefaultTransition: true,
    );
  }

  void _clearErrorMessage() {
    if (_errorMessage != null && mounted) {
      setState(() {
        _errorMessage = null;
      });

      _formKey.currentState?.validate();

      try {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      } catch (_) {}
    }
  }

  Future<void> _navigateToSignup() async {
    if (!mounted || _isLoading) return;

    try {
      _clearErrorMessage();

      navigateTo(context, const SignupSelection(), "/auth/signup");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาดในการเปิดหน้าสมัครสมาชิก กรุณาลองใหม่อีกครั้ง',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showRoleSelectionDialog(
    List<AvailableRole> availableRoles,
  ) async {
    final selectedRole = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกบทบาท'),
          content: const Text(
            'คุณมีบัญชีหลายบัญชีสำหรับเบอร์โทรนี้ กรุณาเลือกบทบาทที่ต้องการเข้าสู่ระบบ:',
          ),
          actions: [
            ...availableRoles.map((roleData) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(roleData.role);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        roleData.roleDisplayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        roleData.fullName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop('USE_ANOTHER_ACCOUNT');
                },
                style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ใช้บัญชีอื่น',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (selectedRole != null) {
      if (selectedRole == 'USE_ANOTHER_ACCOUNT') {
        _clearFormAndFocus();
      } else {
        await _loginWithRole(selectedRole);
      }
    }
  }

  void _clearFormAndFocus() {
    setState(() {
      _phoneController.clear();
      _passwordController.clear();
      _errorMessage = null;
    });

    FocusScope.of(context).requestFocus(FocusNode());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลบัญชีที่ต้องการใช้งาน'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loginWithRole(String role) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.loginWithRole(
        _phoneController.text,
        _passwordController.text,
        role,
      );

      await _handleAuthResult(result);
    } catch (e) {
      log('Error during role-based login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 82,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 32,
                    children: [
                      _buildHeader(),
                      if (_errorMessage != null) _buildErrorMessage(theme),
                      _buildLoginForm(),
                    ],
                  ),
                ),
              ),
            ),

            _buildSignUpLink(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(_logoPath, width: 120, height: 120),
        const SizedBox(height: 16),
        const Text(
          "เข้าสู่ระบบ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          semanticsLabel: 'หน้าเข้าสู่ระบบ',
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      spacing: 14,
      children: [
        PrimaryTextField(
          labelText: 'เบอร์โทรศัพท์',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
          enabled: !_isLoading,
          hintText: '08xxxxxxxx',
          onChanged: (_) => _clearErrorMessage(),
        ),
        PrimaryTextField(
          labelText: 'รหัสผ่าน',
          controller: _passwordController,
          isPassword: true,
          validator: _validatePassword,
          enabled: !_isLoading,
          onChanged: (_) => _clearErrorMessage(),
        ),
        const SizedBox(height: 2),
        PrimaryButton(
          text: _isLoading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
          onPressed: () => _handleLogin(),
          disabled: _isLoading,
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _clearErrorMessage(),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text.rich(
        TextSpan(
          text: 'ยังไม่มีบัญชี? ',
          children: [
            TextSpan(
              text: 'สร้างบัญชีเลย',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _navigateToSignup(),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
