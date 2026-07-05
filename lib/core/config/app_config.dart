import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.environment,
  });

  final String appName;
  final String apiBaseUrl;
  final String environment;

  bool get isDevelopment => environment == 'development';

  factory AppConfig.fromDotEnv() {
    final apiBaseUrl = dotenv.env['API_BASE_URL']?.trim();
    final environment = dotenv.env['ENVIRONMENT']?.trim();
    final appName = dotenv.env['APP_NAME']?.trim();

    if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is missing in env file');
    }

    return AppConfig(
      apiBaseUrl: apiBaseUrl,
      environment: environment == null || environment.isEmpty
          ? 'development'
          : environment,
      appName: appName == null || appName.isEmpty
          ? 'SplitMate'
          : appName,
    );
  }

  factory AppConfig.fromEnvironment() {
    const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    const appName = String.fromEnvironment(
      'APP_NAME',
      defaultValue: 'SPLITMATE',
    );

    if (apiBaseUrl.trim().isEmpty) {
      throw Exception('API_BASE_URL is missing from dart-define');
    }

    return const AppConfig(
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      environment: environment,
    );
  }
}
