import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/product_model.dart';

class HomeApiProvider {
  final Dio dio = ApiClient.dioInstance;

   Future<List<Product>> fetchAllProducts() async {
    final res = await dio.get(Endpoints.products);
    final data = res.data as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> fetchDiscountedProducts() async {
    final res = await dio.get(Endpoints.banners);
    final data = res.data as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }
}
