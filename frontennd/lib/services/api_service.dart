import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://localhost:5000/api';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<http.Response> _authorizedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl$endpoint');
    final bodyJson = body != null ? jsonEncode(body) : null;

    switch (method) {
      case 'POST':
        return http.post(uri, headers: headers, body: bodyJson);
      case 'PUT':
        return http.put(uri, headers: headers, body: bodyJson);
      case 'PATCH':
        return http.patch(uri, headers: headers, body: bodyJson);
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        return http.get(uri, headers: headers);
    }
  }

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await saveToken(data['token']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // ---------- PRODUCTS ----------
  static Future<List<dynamic>> getProducts() async {
    final res = await _authorizedRequest('/products');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createProduct(String name, String category, double price, int stock, String? image, dynamic discount) async {
    final res = await _authorizedRequest(
      '/products/create',
      method: 'POST',
      body: {'name': name, 'category': category, 'price': price, 'stock': stock, 'image': image, 'discount': discount},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProduct(String id, String name, String category, double price, int stock, String? image, dynamic discount) async {
    final res = await _authorizedRequest(
      '/products/update/$id',
      method: 'PUT',
      body: {'name': name, 'category': category, 'price': price, 'stock': stock, 'image': image, 'discount': discount},
    );
    return jsonDecode(res.body);
  }

  static Future<void> deleteProduct(String id) async {
    await _authorizedRequest('/products/delete/$id', method: 'DELETE');
  }

  // ---------- ORDERS ----------
  static Future<List<dynamic>> getMyOrders() async {
    final res = await _authorizedRequest('/orders/my');
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyOrdered() async {
    final res = await _authorizedRequest('/orders/mine');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    final res = await _authorizedRequest('/orders', method: 'POST', body: body);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getOrderById(String id) async {
    final res = await _authorizedRequest('/orders/$id');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    final res = await _authorizedRequest(
      '/orders/$id/status',
      method: 'PATCH',
      body: {'status': status},
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteOrder(String id) async {
    final res = await _authorizedRequest('/orders/$id', method: 'DELETE');
    return jsonDecode(res.body);
  }

  // ---------- USER ----------
  static Future<Map<String, dynamic>> getUserProfile() async {
    final res = await _authorizedRequest('/user/profile');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final res = await _authorizedRequest('/user/profile', method: 'PUT', body: data);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getUserAccount() async {
    final res = await _authorizedRequest('/user/account');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateUserAccount(Map<String, dynamic> data) async {
    final res = await _authorizedRequest('/user/account', method: 'PUT', body: data);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getUserPreferences() async {
    final res = await _authorizedRequest('/user/preferences');
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateUserPreferences(Map<String, dynamic> data) async {
    final res = await _authorizedRequest('/user/preferences', method: 'PUT', body: data);
    return jsonDecode(res.body);
  }

  // ---------- PROMOS ----------
  static Future<List<dynamic>> getPromotions() async {
    final res = await _authorizedRequest('/promotions');
    return jsonDecode(res.body);
  }
}
