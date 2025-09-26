import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/button.dart';

class SignupSelection extends StatelessWidget {
  const SignupSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 82,
                  ),
                  child: Column(
                    spacing: 4,
                    children: [
                      const Text(
                        "คุณเป็น..?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(text: "ผู้ใช้งานทั่วไป", onPressed: () {}),
                      PrimaryButton(text: "ไรเดอร์", onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ),

            Text.rich(
              TextSpan(
                text: 'มีบัญชีอยู่แล้ว? ',
                children: [
                  TextSpan(
                    text: 'เข้าสู่ระบบเลย',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.pop(context),
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
