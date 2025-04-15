import '../data/models/product_model.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Product> banners;
  final List<Product> products;
  final List<Product> filteredProducts;

   HomeLoaded({
    required this.banners,
    required this.products,
    List<Product>? filteredProducts,
  }) : filteredProducts = filteredProducts ?? products;
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
