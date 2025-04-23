import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/home_bloc.dart';
import '../logic/home_event.dart';
import '../logic/home_state.dart';
import './widgets/banner_slider.dart';
import './widgets/product_card.dart';
import './widgets/search_field.dart';
import './widgets/discounted_section.dart';
import './widgets/product_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 252, 249),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 36,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              'Market DZ',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF00826C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF00826C)),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00826C)));
          } else if (state is HomeLoaded) {
            // --- HomeScreen content starts here ---
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Welcome header
                Text(
                  "Welcome back 👋",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF00826C),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Discover fresh products and exclusive deals!",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                // Search Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    // child: SearchField(),
                  ),
                ),
                const SizedBox(height: 24),
                // Discounted Section (BannerSlider or DiscountedSection)
                DiscountedSection(products: state.discountedProducts),
                const SizedBox(height: 24),
                // Grouped Product Sections by Category
                ..._buildProductSections(state.allProducts),
              ],
            );
            // --- HomeScreen content ends here ---
          } else if (state is HomeError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00826C),
        unselectedItemColor: Colors.black38,
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  List<Widget> _buildProductSections(List allProducts) {
    final Map<String, List> grouped = {};
    for (var product in allProducts) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }
    return grouped.entries
        .map((e) => ProductSection(category: e.key, products: e.value.cast()))
        .toList();
  }
}
