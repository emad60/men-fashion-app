import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  double get totalAmount {
    return _items.fold(0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
  }

  void addItem(Product product, String size) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.size == size
    );

    if (existingIndex >= 0) {
    _items[existingIndex].quantity++;
  } else {
    _items.add(CartItem(
      product: product,
      size: size,
      quantity: 1,
    ));
  }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id.toString() == productId);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _items.remove(item);
    } else {
      item.quantity = newQuantity;
    }
    notifyListeners();
  }

  void updateSize(CartItem item, String newSize) {
    final existingIndex = _items.indexWhere(
      (i) => i.product.id == item.product.id && i.size == newSize
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
      _items.remove(item);
    } else {
      item.size = newSize;
    }
    notifyListeners();
  }

  // For snackbar context
  static BuildContext? globalContext;

  addToCart(Product product) {}
}