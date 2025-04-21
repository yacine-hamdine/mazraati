import 'package:flutter/material.dart';
import 'package:frontend/features/home/data/models/product_model.dart';
import 'package:frontend/features/home/presentation/screens/product_detail_page.dart';
import 'dart:convert';

class ProductSection extends StatelessWidget {
  final String category;
  final List<Product> products;

  const ProductSection(
      {super.key, required this.category, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...products.map((product) {
          final seller = product.sellers.first;
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
            contentPadding: EdgeInsets.zero,
            leading: seller.image.isNotEmpty
                ? Image.memory(
                    base64Decode(seller.image),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 50),
            title: Text(product.name),
            subtitle: Text("${seller.price} DA • Stock: ${seller.stock}"),
            trailing: seller.discounts?.isActive == true
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "-${seller.discounts!.percentage.toStringAsFixed(0)}%",
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
}
