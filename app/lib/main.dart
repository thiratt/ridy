import 'package:app/models/user_signup_draft.dart';
import 'package:app/pages/auth/login/page.dart';
import 'package:app/pages/auth/signup/page.dart';
import 'package:app/pages/auth/signup/rider/page.dart';
import 'package:app/pages/auth/signup/user/add_address.dart';
import 'package:app/pages/auth/signup/user/page.dart';
import 'package:app/pages/auth/signup/user/select_address.dart';
import 'package:app/pages/home/user/page.dart';
import 'package:app/pages/onboarding.dart';
import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
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
          switch (settings.name) {
            case '/auth/signup/user/address/add':
              final args = settings.arguments as Map<String, dynamic>?;
              final draft = args != null && args['draft'] is UserSignupDraft
                  ? args['draft'] as UserSignupDraft
                  : null;
              if (draft != null) {
                return UserSignupAddAddressPage(draft: draft);
              }
              break;
            case '/home/user':
              final uid = settings.arguments as String?;
              if (uid != null) {
                return UserHomePage(uid: uid);
              }
              break;
          }
          return const OnBoardingPage();
        },
        settings: settings,
      ),
    );
  }
}
