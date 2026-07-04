class AppConfig {
  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.environment,
  });

  final String appName;
  final String apiBaseUrl;
  final String environment;

  const AppConfig.fromEnvironment()
      : appName = const String.fromEnvironment(
          'APP_NAME',
          defaultValue: 'SplitMate',
        ),
        apiBaseUrl = const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:5000',
        ),
        environment = const String.fromEnvironment(
          'ENVIRONMENT',
          defaultValue: 'development',
        );

  bool get isDevelopment => environment == 'development';
}