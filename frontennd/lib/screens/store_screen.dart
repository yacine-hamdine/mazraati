import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_main_button.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<dynamic> myProducts = [];
  bool loading = true;
  bool adding = false;
  bool editing = false;
  String? error;

  // Add product controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  Uint8List? productImageBytes;
  String? productImageBase64;
  ProductName? selectedProductName;
  double? discountPercentage;
  DateTime? discountExpiry;

  @override
  void initState() {
    super.initState();
    fetchMyProducts();
  }

  Future<void> fetchMyProducts() async {
    setState(() {
      loading = true;
    });
    try {
      final user = await ApiService.getUserProfile();
      final allProducts = await ApiService.getProducts();
      final userId = user['_id'] ?? user['id'];
      myProducts = allProducts.where((p) => p['seller']?['_id'] == userId).toList();
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement';
        loading = false;
      });
    }
  }

  Future<void> pickProductImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        productImageBytes = bytes;
        productImageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
  }

  // Helper to infer category from product name
  ProductCategory? getCategoryForProduct(ProductName? productName) {
    if (productName == null) return null;
    // Map each ProductName to its ProductCategory
    switch (productName) {
      // Vegetables
      case ProductName.tomatoes:
      case ProductName.potatoes:
      case ProductName.onions:
      case ProductName.carrots:
      case ProductName.cucumbers:
      case ProductName.lettuce:
      case ProductName.spinach:
      case ProductName.broccoli:
      case ProductName.peppers:
      case ProductName.zucchini:
        return ProductCategory.vegetables;
      // Fruits
      case ProductName.apples:
      case ProductName.oranges:
      case ProductName.bananas:
      case ProductName.grapes:
      case ProductName.pears:
      case ProductName.strawberries:
      case ProductName.blueberries:
      case ProductName.lemons:
      case ProductName.mangoes:
      case ProductName.watermelons:
        return ProductCategory.fruits;
      // Grains
      case ProductName.wheat:
      case ProductName.barley:
      case ProductName.corn:
      case ProductName.rice:
      case ProductName.oats:
        return ProductCategory.grains;
      // Dairy
      case ProductName.milk:
      case ProductName.cheese:
      case ProductName.butter:
      case ProductName.yogurt:
        return ProductCategory.dairy;
      // Meat
      case ProductName.beef:
      case ProductName.lamb:
      case ProductName.goat:
      case ProductName.camel:
        return ProductCategory.meat;
      // Poultry
      case ProductName.chicken:
      case ProductName.duck:
      case ProductName.turkey:
        return ProductCategory.poultry;
      // Eggs
      case ProductName.chicken_eggs:
      case ProductName.duck_eggs:
        return ProductCategory.eggs;
      // Honey
      case ProductName.wild_honey:
      case ProductName.organic_honey:
      case ProductName.beeswax:
        return ProductCategory.honey;
      // Nuts
      case ProductName.almonds:
      case ProductName.walnuts:
      case ProductName.peanuts:
      case ProductName.pistachios:
        return ProductCategory.nuts;
      // Herbs
      case ProductName.mint:
      case ProductName.parsley:
      case ProductName.basil:
      case ProductName.oregano:
      case ProductName.thyme:
        return ProductCategory.herbs;
      // Plants
      case ProductName.succulents:
      case ProductName.basil_plants:
      case ProductName.tomato_seedlings:
      case ProductName.aloe_vera:
        return ProductCategory.plants;
      // Beverages
      case ProductName.milk_tea:
      case ProductName.herbal_tea:
      case ProductName.fresh_juice:
        return ProductCategory.beverages;
      // Baked
      case ProductName.bread:
      case ProductName.pastries:
      case ProductName.cakes:
        return ProductCategory.baked;
      // Oils
      case ProductName.olive_oil:
      case ProductName.sunflower_oil:
      case ProductName.argan_oil:
        return ProductCategory.oils;
      default:
        return null;
    }
  }

  Future<void> addProduct() async {
    setState(() {
      adding = true;
      error = null;
    });
    try {
      final stock = int.tryParse(stockController.text.trim()) ?? 0;
      final price = double.tryParse(priceController.text.trim()) ?? 0.0;
      final category = getCategoryForProduct(selectedProductName);
      if (selectedProductName == null || productImageBase64 == null || category == null) {
        setState(() {
          error = "Nom du produit, catégorie et photo requis";
          adding = false;
        });
        return;
      }
      final discount = (discountPercentage != null && discountExpiry != null)
          ? {
              'percentage': discountPercentage,
              'expiresAt': discountExpiry!.toIso8601String(),
            }
          : null;
      await ApiService.createProduct(
        selectedProductName!.name,
        category.name,
        price,
        stock,
        productImageBase64,
        discount,
      );
      nameController.clear();
      stockController.clear();
      priceController.clear();
      productImageBytes = null;
      productImageBase64 = null;
      selectedProductName = null;
      discountPercentage = null;
      discountExpiry = null;
      await fetchMyProducts();
    } catch (e) {
      setState(() {
        error = "Erreur lors de l'ajout";
      });
    }
    setState(() {
      adding = false;
    });
  }

  void showEditProductSheet(dynamic product) {
    final TextEditingController editStock = TextEditingController(text: product['stock'].toString());
    final TextEditingController editPrice = TextEditingController(text: product['price'].toString());
    Uint8List? editImageBytes;
    String? editImageBase64 = product['image'];
    ProductName? editProductName = ProductName.values.firstWhere(
      (p) => p.name == (product['name'] ?? ''),
      orElse: () => ProductName.tomatoes,
    );
    double? editDiscountPercentage = product['discounts']?['percentage']?.toDouble();
    DateTime? editDiscountExpiry = product['discounts']?['expiresAt'] != null
        ? DateTime.tryParse(product['discounts']['expiresAt'])
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text("Modifier le produit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        setModalState(() {
                          editImageBytes = bytes;
                          editImageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: editImageBase64 != null
                          ? Image.memory(
                              base64Decode(editImageBase64!.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(Icons.camera_alt, size: 40, color: Color(0xFF00826C)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<ProductName>(
                    value: editProductName,
                    items: ProductName.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name),
                            ))
                        .toList(),
                    onChanged: (p) {
                      setModalState(() {
                        editProductName = p;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Nom du produit",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: editStock,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantité disponible en stock",
                      suffix: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: const Text("KG", style: TextStyle(color: Color(0xFF00826C))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: editPrice,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Saisissez le prix du KG en DZA",
                      suffix: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: const Text("KG", style: TextStyle(color: Color(0xFF00826C))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Discount fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: editDiscountPercentage?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Remise (%)",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              editDiscountPercentage = double.tryParse(val);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: editDiscountExpiry ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                editDiscountExpiry = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Expire le",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              editDiscountExpiry != null
                                  ? "${editDiscountExpiry!.toLocal()}".split(' ')[0]
                                  : "Choisir une date",
                              style: TextStyle(
                                color: editDiscountExpiry != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00826C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () async {
                      setState(() {
                        editing = true;
                      });
                      final editCategory = getCategoryForProduct(editProductName);
                      final discount = (editDiscountPercentage != null && editDiscountExpiry != null)
                          ? {
                              'percentage': editDiscountPercentage,
                              'expiresAt': editDiscountExpiry!.toIso8601String(),
                            }
                          : null;
                      await ApiService.updateProduct(
                        product['_id'],
                        editProductName!.name,
                        editCategory?.name ?? "vegetables",
                        double.tryParse(editPrice.text.trim()) ?? 0.0,
                        int.tryParse(editStock.text.trim()) ?? 0,
                        editImageBase64,
                        discount,
                      );
                      setState(() {
                        editing = false;
                      });
                      Navigator.pop(context);
                      await fetchMyProducts();
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      await deleteProduct(product['_id']);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
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
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              children: [
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    "Ma boutique",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                const SizedBox(height: 12),
                // Add Product Form
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: pickProductImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: productImageBytes != null
                              ? Image.memory(productImageBytes!, fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt, size: 40, color: Color(0xFF00826C)),
                                    SizedBox(height: 8),
                                    Text("Photo du produit", style: TextStyle(color: Color(0xFF00826C))),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Information du produits",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text(
                        "El fellah stock",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nom du produit",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Quantité disponible en stock",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("KG", style: TextStyle(color: Color(0xFF00826C))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Saisissez le prix du KG en DZA",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("KG", style: TextStyle(color: Color(0xFF00826C))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(error!, style: const TextStyle(color: Colors.red)),
                        ),
                      CustomMainButton(
                        text: "Ajouter a la boutique",
                        onPressed: adding ? null : addProduct,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Product List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Vos produits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      if (myProducts.isEmpty)
                        const Center(child: Text("Aucun produit dans votre boutique")),
                      ...myProducts.map((product) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: product['image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(product['image'].replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image, size: 48, color: Color(0xFF00826C)),
                              title: Text(product['name'] ?? ''),
                              subtitle: Text(
                                  "Stock: ${product['stock']} KG\nPrix: ${product['price']} DZA/KG"),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF00826C)),
                                onPressed: () => showEditProductSheet(product),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Future<void> deleteProduct(String id) async {
    await ApiService.deleteProduct(id);
    await fetchMyProducts();
  }
}
