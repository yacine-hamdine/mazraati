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

  // Add this to store the current userId
  String? currentUserId;

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
      currentUserId = userId; // Store userId in state
      myProducts = allProducts.where((p) {
        final sellers = p['sellers'] as List<dynamic>? ?? [];
        return sellers.any((seller) => seller['_id'] == userId);
      }).toList();
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
      // Légumes
      case ProductName.tomates:
      case ProductName.pommes_de_terre:
      case ProductName.oignons:
      case ProductName.carottes:
      case ProductName.concombres:
      case ProductName.laitue:
      case ProductName.epinards:
      case ProductName.brocoli:
      case ProductName.poivrons:
      case ProductName.courgettes:
        return ProductCategory.legumes;
      // Fruits
      case ProductName.pommes:
      case ProductName.oranges:
      case ProductName.bananes:
      case ProductName.raisins:
      case ProductName.poires:
      case ProductName.fraises:
      case ProductName.myrtilles:
      case ProductName.citrons:
      case ProductName.mangues:
      case ProductName.pasteques:
        return ProductCategory.fruits;
      // Céréales
      case ProductName.ble:
      case ProductName.orge:
      case ProductName.mais:
      case ProductName.riz:
      case ProductName.avoine:
        return ProductCategory.cereales;
      // Produits Laitiers
      case ProductName.lait:
      case ProductName.fromage:
      case ProductName.beurre:
      case ProductName.yaourt:
        return ProductCategory.produits_laitiers;
      // Viande
      case ProductName.boeuf:
      case ProductName.agneau:
      case ProductName.chevre:
      case ProductName.chameau:
        return ProductCategory.viande;
      // Volaille
      case ProductName.poulet:
      case ProductName.canard:
      case ProductName.dinde:
        return ProductCategory.volaille;
      // Œufs
      case ProductName.oeufs_de_poule:
      case ProductName.oeufs_de_canard:
        return ProductCategory.oeufs;
      // Miel
      case ProductName.miel_sauvage:
      case ProductName.miel_bio:
      case ProductName.cire_d_abeille:
        return ProductCategory.miel;
      // Noix
      case ProductName.amandes:
      case ProductName.noix:
      case ProductName.cacahuetes:
      case ProductName.pistaches:
        return ProductCategory.noix;
      // Herbes
      case ProductName.menthe:
      case ProductName.persil:
      case ProductName.basilic:
      case ProductName.origan:
      case ProductName.thym:
        return ProductCategory.herbes;
      // Plantes
      case ProductName.succulentes:
      case ProductName.plants_de_basilic:
      case ProductName.plants_de_tomates:
      case ProductName.aloe_vera:
        return ProductCategory.plantes;
      // Boissons
      case ProductName.the_au_lait:
      case ProductName.tisane:
      case ProductName.jus_frais:
        return ProductCategory.boissons;
      // Produits de Boulangerie
      case ProductName.pain:
      case ProductName.patisseries:
      case ProductName.gateaux:
        return ProductCategory.produits_de_boulangerie;
      // Huiles
      case ProductName.huile_d_olive:
      case ProductName.huile_de_tournesol:
      case ProductName.huile_d_argan:
        return ProductCategory.huiles;
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
    final sellers = product['sellers'] as List<dynamic>? ?? [];
    final mySeller = sellers.firstWhere(
      (seller) => seller['_id'] == currentUserId,
      orElse: () => null,
    );
  
    if (mySeller == null) {
      setState(() {
        error = "Seller not found for this product.";
      });
      return;
    }
  
    final TextEditingController editStock = TextEditingController(text: mySeller['stock'].toString());
    final TextEditingController editPrice = TextEditingController(text: mySeller['price'].toString());
    Uint8List? editImageBytes;
    String? editImageBase64 = mySeller['image'];
    ProductName? editProductName = ProductName.values.firstWhere(
      (p) => p.name == (product['name'] ?? ''),
      orElse: () => ProductName.tomates,
    );
    double? editDiscountPercentage = mySeller['discounts']?['percentage']?.toDouble();
    DateTime? editDiscountExpiry = mySeller['discounts']?['expiresAt'] != null
        ? DateTime.tryParse(mySeller['discounts']['expiresAt'])
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
                        child: const Text("DZA", style: TextStyle(color: Color(0xFF00826C))),
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
                  CustomMainButton(
                    text: "Enregistrer",
                    onPressed: adding ? null : () async {
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
                      const Text(
                        "Publier un produit",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text(
                        "Mazraati Marketplace",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
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
                      // Product name selection (enum)
                      DropdownButtonFormField<ProductName>(
                        value: selectedProductName,
                        items: ProductName.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ))
                            .toList(),
                        onChanged: (p) {
                          setState(() {
                            selectedProductName = p;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Nom du produit",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Category display (inferred)
                      Text(
                        selectedProductName != null
                            ? "Catégorie: ${getCategoryForProduct(selectedProductName)?.name ?? ''}"
                            : "Catégorie: ",
                        style: const TextStyle(color: Color(0xFF00826C), fontWeight: FontWeight.bold),
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
                            child: const Text("DZA", style: TextStyle(color: Color(0xFF00826C))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Discount fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: discountPercentage?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Remise (%)",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  discountPercentage = double.tryParse(val);
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
                                  initialDate: discountExpiry ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    discountExpiry = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Expire le",
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  discountExpiry != null
                                      ? "${discountExpiry!.toLocal()}".split(' ')[0]
                                      : "Choisir une date",
                                  style: TextStyle(
                                    color: discountExpiry != null ? Colors.black : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
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
                      ...myProducts.map((product) {
                            final sellers = product['sellers'] as List<dynamic>? ?? [];
                            final mySeller = sellers.firstWhere(
                              (seller) => seller['_id'] == currentUserId,
                              orElse: () => null,
                            );
                            final imageBase64 = mySeller != null ? mySeller['image'] : null;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: imageBase64 != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(imageBase64.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.image, size: 48, color: Color(0xFF00826C)),
                                title: Text(product['name'] ?? ''),
                                subtitle: Text(
                                    "Stock: ${mySeller != null ? mySeller['stock'] : '-'} KG\nPrix: ${mySeller != null ? mySeller['price'] : '-'} DZA/KG"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF00826C)),
                                  onPressed: () => showEditProductSheet(product),
                                ),
                              ),
                            );
                          }),
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
