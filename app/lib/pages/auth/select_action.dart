import 'package:app/pages/auth/login.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';

class SelectActionPage extends StatefulWidget {
  const SelectActionPage({super.key});

  @override
  State<SelectActionPage> createState() => _SelectActionPageState();
}

class _SelectActionPageState extends State<SelectActionPage> {
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                ),
                OutlinedAppButton(text: "สมัครสมาชิก", onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
