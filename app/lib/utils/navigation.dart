import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> navigateTo<T extends Object?>(
  BuildContext context,
  Widget page,
  String routeName,
) async {
  return await Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (_) => page,
      settings: RouteSettings(name: routeName),
    ),
  );
}

Future<T> navigateReplaceTo<T extends Object?>(
  BuildContext context,
  Widget page,
  String routeName, {
  bool useDefaultTransition = false,
}) async {
  return await Navigator.pushReplacement(
    context,
    !useDefaultTransition
        ? CupertinoPageRoute(
            builder: (_) => page,
            settings: RouteSettings(name: routeName),
          )
        : MaterialPageRoute(
            builder: (_) => page,
            settings: RouteSettings(name: routeName),
          ),
  );
}
