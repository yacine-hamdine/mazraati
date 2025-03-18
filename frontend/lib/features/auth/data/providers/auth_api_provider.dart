import 'package:dio/dio.dart';
// Adjust the import paths as needed:
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/user_model.dart';

class AuthApiProvider {
  final Dio _dio = ApiClient.dioInstance;

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.register, // e.g., '/api/users/register'
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      // Assuming your backend returns user data under response.data['user']
      return UserModel.fromJson(response.data['user']);
    } on DioError catch (e) {
      // You can customize error handling here
      throw Exception(e.response?.data['message'] ?? 'Register error');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.login, // e.g., '/api/users/login'
        data: {
          'email': email,
          'password': password,
        },
      );
      // Assuming your backend returns user data under response.data['user']
      return UserModel.fromJson(response.data['user']);
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login error');
    }
  }
}
