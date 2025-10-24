import 'package:app/utils/env.dart';

sealed class ApiRoute {
  final String path;
  const ApiRoute(this.path);

  static const login = _RidyRoute('/account/login');
  static const loginWithRole = _RidyRoute('/account/login/select-role');
  static const checkPhoneNumber = _RidyRoute('/account/check-phone');
}

class _RidyRoute extends ApiRoute {
  const _RidyRoute(super.path);
}

class ApiConstants {
  static String baseUrl = getEnv('BASE_URL');
  static String buildUrlEndpoint(ApiRoute route) => '$baseUrl${route.path}';
}
