import 'package:app/pages/onboarding.dart';
import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const OnBoardingPage(),
    );
  }
}
