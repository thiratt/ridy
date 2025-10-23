import 'package:flutter/cupertino.dart';

void navigateTo(BuildContext context, Widget page, String routeName) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (_) => page,
      settings: RouteSettings(name: routeName),
    ),
  );
}
