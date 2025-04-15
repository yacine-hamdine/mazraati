import '../models/product_model.dart';
import '../providers/home_api_provider.dart';

class HomeRepository {
  final HomeApiProvider apiProvider;

  HomeRepository({required this.apiProvider});

  Future<List<Product>> getAllProducts() {
    return apiProvider.fetchAllProducts();
  }

  Future<List<Product>> getDiscountedProducts() {
    return apiProvider.fetchDiscountedProducts();
  }
}
