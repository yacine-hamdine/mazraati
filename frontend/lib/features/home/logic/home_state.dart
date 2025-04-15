import 'package:equatable/equatable.dart';
import 'package:frontend/features/home/data/models/product_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Product> allProducts;
  final List<Product> discountedProducts;

  const HomeLoaded({
    required this.allProducts,
    required this.discountedProducts,
  });

  @override
  List<Object?> get props => [allProducts, discountedProducts];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
