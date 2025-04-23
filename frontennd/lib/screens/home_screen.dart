import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_main_button.dart';
import '../services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  bool loading = true;
  int _bannerIndex = 0;

  List<dynamic> promotions = [];
  bool promotionsLoading = true;

  PageController? _pageController;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchPromotions();
    _pageController = PageController(initialPage: 0);
    _startBannerAutoSlide();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController != null && promotions.length > 1) {
        int nextPage = (_bannerIndex + 1) % (promotions.length > 3 ? 3 : promotions.length);
        _pageController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final result = await ApiService.getProducts();
      setState(() {
        products = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint('Error fetching products: $e');
    }
  }

  List<Uint8List?> promotionImages = [];

  Future<void> fetchPromotions() async {
    try {
      final result = await ApiService.getPromotions();
      // Decode images once and cache them
      final images = result.map<Uint8List?>((promo) {
        final imageStr = promo['seller']['image'];
        if (imageStr != null && imageStr is String && imageStr.isNotEmpty) {
          try {
            return base64Decode(
              imageStr.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), ''),
            );
          } catch (_) {
            return null;
          }
        }
        return null;
      }).toList();

      setState(() {
        promotions = result;
        promotionsLoading = false;
        promotionImages = images;
      });
    } catch (e) {
      setState(() {
        promotionsLoading = false;
      });
      debugPrint('Error fetching promotions: $e');
    }
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
          : RefreshIndicator(
              onRefresh: fetchProducts,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "Promotions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  // Banner Widget updated to slider
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: promotionsLoading || promotions.isEmpty
                        ? Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          )
                        : SizedBox(
                            height: 120,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: promotions.length > 3 ? 3 : promotions.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _bannerIndex = index;
                                });
                              },
                              itemBuilder: (context, idx) {
                                final promo = promotions[idx];
                                final seller = promo['seller'];
                                final imageStr = seller['image'];
                                final imageBytes = promotionImages.length > idx ? promotionImages[idx] : null;
                                Widget imageWidget;
                                if (imageBytes != null) {
                                  imageWidget = Image.memory(
                                    imageBytes,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  imageWidget = Container(
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Center(child: Icon(Icons.image_not_supported)),
                                  );
                                }
                                return Stack(
                                  children: [
                                    imageWidget,
                                    Positioned(
                                      left: 16,
                                      bottom: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${seller['discount']['percentage'].toString()}% off",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            seller['name'] ?? "None",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  // Page indicator (dynamic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      promotions.length > 3 ? 3 : promotions.length,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _bannerIndex == idx ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _bannerIndex == idx
                              ? const Color(0xFF00916E)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Products Section
                  const Text(
                    "Produits",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Trouvez Des produits frais",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  // Products Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final sellers = product['sellers'] as List<dynamic>;
                      final firstSeller = sellers.isNotEmpty ? sellers[0] : null;
                      return GestureDetector(
                        onTap: () => _showProductBottomSheet(product, firstSeller),
                        child: _ProductCard(product: product, seller: firstSeller),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
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
        // It's a base64 image string
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
        // It's a URL
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
                  ),
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

class ProductBottomSheet extends StatefulWidget {
  final dynamic product;
  final dynamic seller;

  const ProductBottomSheet({required this.product, required this.seller});

  @override
  State<ProductBottomSheet> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  final TextEditingController _weightController = TextEditingController();
  String _unit = "KG";

  @override
  Widget build(BuildContext context) {
    Widget sellerImageWidget;
    if (widget.seller?['image'] != null && widget.seller['image'].isNotEmpty) {
      if (widget.seller['image'].startsWith('data:image')) {
        final base64Str = widget.seller['image'].replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
        sellerImageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(base64Str),
            height: 90,
            fit: BoxFit.contain,
          ),
        );
      } else {
        sellerImageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.seller['image'],
            height: 90,
            fit: BoxFit.contain,
          ),
        );
      }
    } else {
      sellerImageWidget = const Icon(Icons.agriculture, size: 64);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: sellerImageWidget),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.product['name'] ?? 'Produit',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Text(
                widget.seller != null ? "${widget.seller['price']} DZA/KG" : '',
                style: const TextStyle(
                  color: Color(0xFF00916E),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.seller?['name'] ?? 'El fellah stock',
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                    hintText: "Saisissez le poid que vous voulez acheter",
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00826C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _unit,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    dropdownColor: const Color(0xFF00826C),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    items: const [
                      DropdownMenuItem(
                        value: "KG",
                        child: Text("KG", style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "G",
                        child: Text("G", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _unit = val);
                    },
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
      )],
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: CustomMainButton(
              text: "Ajouter au panier",
              onPressed: () {
                final weight = double.tryParse(_weightController.text) ?? 1.0;
                CartService().addToCart(
                  CartItem(
                    product: widget.product,
                    seller: widget.seller,
                    weight: weight,
                    unit: _unit,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
