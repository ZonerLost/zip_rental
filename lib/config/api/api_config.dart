class ApiConfig {
  const ApiConfig._();

  static const String productionBaseUrl =
      'https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: productionBaseUrl,
  );
}
