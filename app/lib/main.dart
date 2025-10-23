import 'package:app/models/user_signup_draft.dart';
import 'package:app/pages/auth/login/page.dart';
import 'package:app/pages/auth/signup/page.dart';
import 'package:app/pages/auth/signup/rider/page.dart';
import 'package:app/pages/auth/signup/user/add_address.dart';
import 'package:app/pages/auth/signup/user/page.dart';
import 'package:app/pages/auth/signup/user/select_address.dart';
import 'package:app/pages/onboarding.dart';
import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const RidyApplication());
}

class RidyApplication extends StatelessWidget {
  const RidyApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnBoardingPage(),
        '/auth/login': (context) => const LoginPage(),
        '/auth/signup': (context) => const SignupSelection(),
        '/auth/signup/user': (context) => const UserSignupPage(),
        '/auth/signup/user/address/select': (context) =>
            const SelectLocationPage(),
        '/auth/signup/rider': (context) => const RiderSignupPage(),
      },
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) {
          if (settings.name == '/auth/signup/user/address') {
            final args = settings.arguments as Map<String, dynamic>?;
            final draft = args != null && args['draft'] is UserSignupDraft
                ? args['draft'] as UserSignupDraft
                : null;
            if (draft != null) {
              return UserSignupAddAddressPage(draft: draft);
            }
          }
          return const OnBoardingPage();
        },
        settings: settings,
      ),
    );
  }
}
