import 'package:flutter/cupertino.dart';

void navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (context) => page,
    ),
  );
}