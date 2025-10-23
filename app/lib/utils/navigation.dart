import 'package:flutter/cupertino.dart';

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
