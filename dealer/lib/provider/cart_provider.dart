import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  Map<String, int> cart = {};
  int totalAmount = 0;

  int get totalItems => cart.values.fold(0, (sum, qty) => sum + qty);

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    final cartString = prefs.getString("cart");

    if (cartString != null) {
      cart = Map<String, int>.from(jsonDecode(cartString));
    }

    totalAmount = prefs.getInt("amount") ?? 0;
    notifyListeners();
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("cart", jsonEncode(cart));
    await prefs.setInt("amount", totalAmount);
  }

  void updateTotal(List products) {
    totalAmount = 0;

    for (var item in products) {
      final name = item["product_name"];
      final qty = cart[name] ?? 0;
      final price = int.parse(item["unit_price_per_ton"].toString());

      totalAmount += qty * price;
    }

    notifyListeners();
  }

  Future<void> addItem(String productName, List products) async {
    cart[productName] = 1;
    updateTotal(products);
    await saveCart();
  }

  Future<void> increaseItem(String productName, List products) async {
    cart[productName] = (cart[productName] ?? 0) + 1;
    updateTotal(products);
    await saveCart();
  }

  Future<void> decreaseItem(String productName, List products) async {
    if (cart[productName] == 1) {
      cart.remove(productName);
    } else {
      cart[productName] = cart[productName]! - 1;
    }

    updateTotal(products);
    await saveCart();
  }
}