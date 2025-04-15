import 'package:frontend/features/home/data/models/seller_model.dart';

class Product {
  final String category;
  final String name;
  final List<Seller> sellers;

  Product({
    required this.category,
    required this.name,
    required this.sellers,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      category: json['category'],
      name: json['name'],
      sellers: (json['sellers'] as List)
          .map((sellerJson) => Seller.fromJson(sellerJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'name': name,
      'sellers': sellers.map((seller) => seller.toJson()).toList(),
    };
  }
}
