import 'package:flutter/material.dart';
import 'package:frontend/features/home/data/models/product_model.dart';
import 'package:frontend/features/home/data/models/seller_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bestSeller = product.sellers.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.network(bestSeller.image, height: 250, fit: BoxFit.cover),
          const SizedBox(height: 16),
          Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Category: ${product.category}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Text("${bestSeller.price} DA", style: const TextStyle(fontSize: 20)),
          if (bestSeller.discounts?.isActive == true)
            Text(
              "-${bestSeller.discounts!.percentage.toStringAsFixed(0)}% until ${bestSeller.discounts!.expiresAt.toLocal()}",
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 24),
          const Text("Sellers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...product.sellers.map(_buildSellerTile),
        ],
      ),
    );
  }

  Widget _buildSellerTile(Seller seller) {
    return Card(
      child: ListTile(
        leading: Image.network(seller.image, width: 48, height: 48, fit: BoxFit.cover),
        title: Text("${seller.price} DA"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stock: ${seller.stock}"),
            if (seller.discounts?.isActive == true)
              Text("-${seller.discounts!.percentage.toStringAsFixed(0)}% active", style: const TextStyle(color: Colors.red)),
            Text("⭐ ${seller.ratings.toStringAsFixed(1)} (${seller.reviews} reviews)"),
          ],
        ),
      ),
    );
  }
}
