import '../models/product_model.dart';
import '../providers/home_api_provider.dart';

class HomeRepository {
  final _provider = HomeApiProvider();
  final homeRepository = HomeRepository();

  Future<List<Product>> getProducts() => _provider.fetchAllProducts();
  Future<List<Product>> getBanners() => _provider.fetchDiscountedProducts();
  
}
