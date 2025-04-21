import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/product_model.dart';

class HomeApiProvider {
  Future<List<Product>> fetchAllProducts() async {
    try {
      final res = await ApiClient.dioInstance.get(Endpoints.products);
      final List data = res.data as List;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> fetchDiscountedProducts() async {
    final res = await ApiClient.dioInstance.get(Endpoints.banners);
    final data = res.data as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
