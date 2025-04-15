import 'package:frontend/features/home/data/models/discount_model.dart';

class Seller {
  final String id;
  final String image;
  final double price;
  final int stock;
  final Discount? discounts;
  final double ratings;
  final int reviews;
  final DateTime createdAt;

  Seller({
    required this.id,
    this.image = '',
    required this.price,
    required this.stock,
    this.discounts,
    this.ratings = 0,
    this.reviews = 0,
    required this.createdAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      discounts: json['discounts'] != null
          ? Discount.fromJson(json['discounts'])
          : null,
      ratings: (json['ratings'] as num?)?.toDouble() ?? 0,
      reviews: json['reviews'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'price': price,
      'stock': stock,
      'discounts': discounts?.toJson(),
      'ratings': ratings,
      'reviews': reviews,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
