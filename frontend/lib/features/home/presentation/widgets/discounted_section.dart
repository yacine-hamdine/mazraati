import 'package:flutter/material.dart';
import 'package:frontend/features/home/data/models/product_model.dart';

class DiscountedSection extends StatelessWidget {
  final List<Product> products;

  const DiscountedSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔥 Hot Discounts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              final seller = product.sellers.firstWhere(
                (s) => s.discounts?.isActive ?? false,
                orElse: () => product.sellers.first,
              );

              return Container(
                width: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Image.network(seller.image, fit: BoxFit.cover)),
                    const SizedBox(height: 8),
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("${seller.price} DA", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("-${seller.discounts?.percentage.toStringAsFixed(0)}%", style: const TextStyle(color: Colors.red)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
