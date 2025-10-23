import 'package:app/pages/auth/login/page.dart';
import 'package:app/pages/auth/signup/page.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Image.asset("assets/images/cover.png"),
              Column(
                children: [
                  Image.asset(
                    "assets/images/logo_black.png",
                    width: 120,
                    height: 120,
                  ),
                  const Text(
                    "ยินดีต้อนรับสู่แอป Ridy",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              spacing: 4,
              children: [
                PrimaryButton(
                  text: "เข้าสู่ระบบ",
                  onPressed: () => navigateTo(context, const LoginPage(), "/auth/login"),
                ),
                OutlinedAppButton(
                  text: "สมัครสมาชิก",
                  onPressed: () => navigateTo(context, const SignupSelection(), "/auth/signup"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
