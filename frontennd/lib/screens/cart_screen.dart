import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'dart:convert';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    CartService().addListener(_onCartChanged);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    CartService().removeListener(_onCartChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartService().items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF00826C),
                  labelColor: const Color(0xFF00826C),
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(text: "Panier"),
                    Tab(text: "Commandes"),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Cart Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      "Panier",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const Spacer(),
                    Text(
                      cartItems.length.toString().padLeft(2, '0') + "  Produits",
                      style: const TextStyle(
                        color: Color(0xFF00916E),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text("Aucun article dans le panier"))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          Widget sellerImageWidget;
                          final seller = item.seller;
                          if (seller?['image'] != null && seller['image'].isNotEmpty) {
                            if (seller['image'].startsWith('data:image')) {
                              final base64Str = seller['image'].replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
                              sellerImageWidget = ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(base64Str),
                                  height: 54,
                                  width: 54,
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              sellerImageWidget = ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  seller['image'],
                                  height: 54,
                                  width: 54,
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              leading: sellerImageWidget,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.product['name'] ?? 'Produit',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    item.seller != null ? "${item.seller['price']} DZA/KG" : '',
                                    style: const TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.seller?['name'] ?? 'El fellah stock',
                                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Poids :  ${item.weight.toStringAsFixed(0)} ${item.unit}",
                                    style: const TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                                onPressed: () {
                                  CartService().removeFromCart(index);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text(
                      "Acheter",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00826C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: Purchase logic will be implemented later
                    },
                  ),
                ),
              ),
            ],
          ),
          // Orders Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.receipt_long, size: 60, color: Color(0xFF00826C)),
                SizedBox(height: 16),
                Text(
                  "Aucune commande pour le moment",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
