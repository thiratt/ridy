import 'package:app/models/request/login_request.dart';
import 'package:app/models/response/login_response.dart';
import 'package:app/pages/auth/signup/page.dart';
import 'package:app/pages/home/rider/page.dart';
import 'package:app/widgets/home_wrapper.dart';
import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  static const String _apiEndpoint = 'http://10.0.2.2:5200/account/login';
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
      _handleLoginError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performLogin() async {
    final loginRequest = LoginRequest(
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    final response = await http
        .post(
          Uri.parse(_apiEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: loginRequestToJson(loginRequest),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
          },
        );

    await _handleLoginResponse(response);
  }

  Future<void> _handleLoginResponse(http.Response response) async {
    if (response.statusCode == 200) {
      try {
        final loginResponse = loginResponseFromJson(response.body);
        final userData = loginResponse.data;

        await _navigateToHome(userData.role, userData.id);
      } catch (e) {
        throw 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล';
      }
    } else if (response.statusCode == 401) {
      throw 'เบอร์โทรศัพท์หรือรหัสผ่านไม่ถูกต้อง';
    } else if (response.statusCode >= 500) {
      throw 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง';
    } else {
      throw 'เกิดข้อผิดพลาด: ${response.reasonPhrase ?? 'ไม่ทราบสาเหตุ'}';
    }
  }

  Future<void> _navigateToHome(String role, String userId) async {
    if (!mounted) return;

    _clearErrorMessage();

    final Widget homePage = role == "USER"
        ? HomeWrapper(uid: userId)
        : RiderHomePage(uid: userId);

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => homePage),
      (route) => false,
    );
  }

  void _handleLoginError(String error) {
    setState(() {
      _errorMessage = error;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
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

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupSelection()),
      );
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
                    spacing: 48,
                    children: [
                      _buildHeader(),
                      _buildLoginForm(),
                      if (_errorMessage != null) _buildErrorMessage(theme),
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
