import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dioInstance = Dio(BaseOptions(
    baseUrl: 'http://localhost:5000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static void setToken(String token) {
    dioInstance.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    dioInstance.options.headers.remove('Authorization');
  }
}
