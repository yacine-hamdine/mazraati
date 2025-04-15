import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class BannerSlider extends StatelessWidget {
  final List<Product> banners;

  const BannerSlider({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(banners[index].sellers[index].image),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
