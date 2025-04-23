import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_main_button.dart';
import '../services/cart_service.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  List<String> categories = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      searchQuery = _searchController.text;
      filterProducts();
    });
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    setState(() {
      loading = true;
    });
    try {
      final result = await ApiService.getProducts();
      setState(() {
        allProducts = result;
        categories = [
          'All',
          ...{
            for (var p in result)
              if (p['category'] != null) p['category'].toString()
          }
        ];
        filteredProducts = List.from(result);
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint('Error fetching products: $e');
    }
  }

  void filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        final matchesName = product['name'] != null &&
            product['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategory == 'All' ||
            (product['category'] != null && product['category'].toString() == selectedCategory);
        return matchesName && matchesCategory;
      }).toList();
    });
  }

  void _showProductBottomSheet(dynamic product, dynamic seller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: ProductBottomSheet(product: product, seller: seller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 40,
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rechercher",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: CustomTextField(
                    hintText: "Rechercher un produit",
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                            filterProducts();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00826C) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF00826C) : const Color(0xFFD6E3E2),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF00826C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text("Aucun produit trouvé"))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final sellers = product['sellers'] as List<dynamic>;
                            final firstSeller = sellers.isNotEmpty ? sellers[0] : null;
                            return GestureDetector(
                              onTap: () => _showProductBottomSheet(product, firstSeller),
                              child: _ProductCard(product: product, seller: firstSeller),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final dynamic seller;

  const _ProductCard({required this.product, required this.seller});

  @override
  Widget build(BuildContext context) {
    Widget sellerImageWidget;
    if (seller?['image'] != null && seller['image'].isNotEmpty) {
      if (seller['image'].startsWith('data:image')) {
        final base64Str = seller['image'].replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
        sellerImageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(base64Str),
            height: 70,
            fit: BoxFit.contain,
          ),
        );
      } else {
        sellerImageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            seller['image'],
            height: 70,
            fit: BoxFit.contain,
          ),
        );
      }
    } else {
      sellerImageWidget = const Icon(Icons.agriculture, size: 48);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: sellerImageWidget),
                const SizedBox(height: 8),
                Text(
                  product['name'] ?? 'Produit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    seller?['name'] ?? 'El fellah stock',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  )
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seller != null ? "${seller['price']} DZA/KG" : '',
                      style: const TextStyle(
                        color: Color(0xFF00916E),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF3F8F7),
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Color(0xFF00916E)),
                onPressed: () {},
                iconSize: 20,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}