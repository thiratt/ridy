import 'package:flutter_dotenv/flutter_dotenv.dart';

String getEnv(String key, {String defaultValue = ''}) {
  return dotenv.env[key] ?? defaultValue;
}
