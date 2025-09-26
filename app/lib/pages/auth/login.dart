import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // print('phone=${_phone.text}, pass=${_password.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Column(
                        children: [
                          Image.asset(
                            "assets/images/logo_black.png",
                            width: 120,
                            height: 120,
                          ),
                          const Text(
                            "เข้าสู่ระบบ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        spacing: 14,
                        children: [
                          PrimaryTextField(
                            label: 'เบอร์โทรศัพท์',
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                          ),
                          PrimaryTextField(
                            label: 'รหัสผ่าน',
                            controller: _password,
                            obscureText: true,
                          ),
                          PrimaryButton(
                            text: 'เข้าสู่ระบบ',
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Text.rich(
              TextSpan(
                text: 'ยังไม่มีบัญชี? ',
                children: [
                  TextSpan(
                    text: 'สร้างบัญชีเลย',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
