import 'package:app/utils/env.dart';

sealed class ApiRoute {
  final String path;
  const ApiRoute(this.path);

  static const login = _RidyRoute('/account/login');
  static const loginWithRole = _RidyRoute('/account/login/select-role');
  static const checkPhoneNumber = _RidyRoute('/account/check-phone');
  static const getAllUsers = _RidyRoute('/account');
  static const register = _RidyRoute('/account/signup');

  static const userDeliveries = _RidyRoute('/delivery/user/');
  static const sentDeliveries = _RidyRoute('/delivery/sent/');
  static const receivedDeliveries = _RidyRoute('/delivery/received/');
  static const userDeliveriesByStatus = _RidyRoute(
    '/delivery/user/{v}/status/{v}',
  );
}

class _RidyRoute extends ApiRoute {
  const _RidyRoute(super.path);
}

class ApiConstants {
  static String baseUrl = getEnv('BASE_URL');
  static String buildUrlEndpoint(ApiRoute route) => '$baseUrl${route.path}';
  static String withDynamicSegment(ApiRoute route, String segment) =>
      '$baseUrl${route.path}$segment';
  static String withParseValues(ApiRoute route, List<String> values) {
    String parsedPath = route.path;
    for (var value in values) {
      parsedPath = parsedPath.replaceFirst('{v}', value);
    }
    return '$baseUrl$parsedPath';
  }
}
