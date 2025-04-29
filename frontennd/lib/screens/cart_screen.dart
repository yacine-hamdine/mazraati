import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'dart:convert';
import '../services/api_service.dart'; // <-- Add this import

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Add state for orders
  List<dynamic> myOrders = [];
  bool loadingOrders = false;

  @override
  void initState() {
    super.initState();
    CartService().addListener(_onCartChanged);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        fetchOrders();
      }
    });
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

  // Fetch orders from API
  Future<void> fetchOrders() async {
    setState(() {
      loadingOrders = true;
    });
    try {
      final orders = await ApiService.getMyOrders();
      setState(() {
        myOrders = orders;
        loadingOrders = false;
      });
    } catch (e) {
      setState(() {
        loadingOrders = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch orders: $e')),
      );
    }
  }

  // Place order using API
  Future<void> placeOrder() async {
    final cartItems = CartService().items;
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    // Prepare order body
    final orderBody = {
      "items": cartItems.map((item) => {
        "productId": item.product['_id'],
        "seller": item.seller['_id'],
        "weight": item.weight,
        "unit": item.unit,
        "price": item.seller['price'],
      }).toList(),
      // Add more fields if needed (e.g., address, notes)
    };

    try {
      final res = await ApiService.createOrder(orderBody);
      if (res['success'] == true || res['status'] == 'success' || res['order'] != null) {
        CartService().clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        // Optionally, switch to orders tab and refresh
        _tabController.animateTo(1);
        fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to place order')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  // Delete order using API
  Future<void> deleteOrder(String orderId) async {
    try {
      await ApiService.deleteOrder(orderId);
      setState(() {
        myOrders.removeWhere((order) => order['_id'] == orderId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order: $e')),
      );
    }
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
                    onPressed: placeOrder,
                  ),
                ),
              ),
            ],
          ),
          // Orders Tab
          loadingOrders
              ? const Center(child: CircularProgressIndicator())
              : myOrders.isEmpty
                  ? Center(
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
                    )
                  : RefreshIndicator(
                      onRefresh: fetchOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        itemCount: myOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = myOrders[index];
                          final items = order['items'] as List<dynamic>? ?? [];
                          final status = order['status'] ?? 'En attente';
                          final createdAt = order['createdAt'] ?? '';
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
                            child: ExpansionTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Commande #${order['_id']?.substring(order['_id'].length - 6) ?? ''}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: status == 'completed'
                                          ? Colors.green[100]
                                          : status == 'cancelled'
                                              ? Colors.red[100]
                                              : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: status == 'completed'
                                            ? Colors.green
                                            : status == 'cancelled'
                                                ? Colors.red
                                                : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                createdAt.toString().split('T').first,
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                              children: [
                                ...items.map((item) {
                                  return ListTile(
                                    title: Text(item['productName'] ?? 'Produit'),
                                    subtitle: Text(
                                      "Vendeur: ${item['sellerName'] ?? ''}\nPoids: ${item['weight']} ${item['unit']}",
                                    ),
                                    trailing: Text(
                                      "${item['price']} DZA",
                                      style: const TextStyle(
                                        color: Color(0xFF00916E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      final orderId = order['_id'];
                                      if (orderId != null) {
                                        await deleteOrder(orderId);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
