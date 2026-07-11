class ApiConfig {
  ApiConfig._();

  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://firewatch-tr-backend.onrender.com',
  );

  static const apiBaseUrl = '$backendBaseUrl/api';
}
