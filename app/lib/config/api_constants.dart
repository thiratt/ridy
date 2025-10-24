sealed class ApiRoute {
  final String path;
  const ApiRoute(this.path);

  static const login = _RidyRoute('/account/login');
  static const loginWithRole = _RidyRoute('/account/login/select-role');
}

class _RidyRoute extends ApiRoute {
  const _RidyRoute(super.path);
}

class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5200';
  static String buildUrlEndpoint(ApiRoute route) => '$baseUrl${route.path}';
}
