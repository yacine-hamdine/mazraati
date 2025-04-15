import 'package:dio/dio.dart';

// Optionally, you can store your base URL in app_config.dart or an .env file
class ApiClient {
  static final Dio dioInstance = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:5000', // e.g., 'http://10.0.2.2:3000'
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ),
  );
}
