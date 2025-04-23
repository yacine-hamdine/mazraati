import 'package:flutter/material.dart';

class CartItem {
  final dynamic product;
  final dynamic seller;
  final double weight;
  final String unit;

  CartItem({
    required this.product,
    required this.seller,
    required this.weight,
    required this.unit,
  });
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addToCart(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}