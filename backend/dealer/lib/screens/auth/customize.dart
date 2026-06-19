import 'dart:convert';

import 'package:dealer/widgets/addtocartContainer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customize extends StatefulWidget {
  final String imagePath;
  final String itemName;
  final int? totalAmount;

  const Customize({
    super.key,
    required this.imagePath,
    required this.itemName,
    this.totalAmount,
  });

  @override
  State<Customize> createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  static const int _minLength = 20;
  static const int _maxLength = 60;

  Map<String, int> priceMap = {"angles": 2000, "tmt": 3000, "steel": 2500};

  Map<String, int> cart = {};

  bool isCustomSelected = false;

  String selectedLength = "";

  final TextEditingController lengthController = TextEditingController();

  int get totalAmount => cart.entries.fold(0, (sum, item) {
    return sum + (item.value * (priceMap[item.key] ?? 0));
  });

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  @override
  void dispose() {
    lengthController.dispose();
    super.dispose();
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    String? cartString = prefs.getString("cart");

    if (cartString != null && cartString.isNotEmpty) {
      cart = Map<String, int>.from(jsonDecode(cartString));
    }

    if (!cart.containsKey(widget.itemName)) {
      cart[widget.itemName] = 1;
    }

    setState(() {});
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("cart", jsonEncode(cart));

    await prefs.setInt("amount", totalAmount);
  }

  void _updateCustomLength(String value) {
    if (value.isEmpty) {
      setState(() {
        selectedLength = "";
      });
      return;
    }

    final input = int.tryParse(value);
    if (input == null) {
      return;
    }

    if (input >= _minLength && input <= _maxLength) {
      setState(() {
        selectedLength = "$input feet";
      });
    }
  }

  void _validateCustomLength(String value) {
    if (value.isEmpty) {
      setState(() {
        selectedLength = "";
      });
      return;
    }

    final input = int.tryParse(value);
    if (input == null) {
      lengthController.clear();
      return;
    }

    if (input < _minLength || input > _maxLength) {
      lengthController.clear();
      setState(() {
        selectedLength = "";
      });
      return;
    }

    setState(() {
      selectedLength = "$input feet";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 70,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.imagePath,
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Customize Product",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                          color: Colors.orange.withOpacity(0.1),
                        ),
                        child: Text(
                          widget.itemName,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Select Length",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCustomSelected = false;
                      selectedLength = "40 feet";
                      lengthController.clear();
                    });
                  },
                  child: AtcContainer(
                    length: "40 feet",
                    colores: Colors.grey.withOpacity(0.3),
                    colors: Colors.orange,
                    data: "standard",
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCustomSelected = false;
                      selectedLength = "48 feet";
                      lengthController.clear();
                    });
                  },
                  child: AtcContainer(
                    length: "48 feet",
                    colores: Colors.grey.withOpacity(0.3),
                    colors: Colors.blue,
                    data: "extralong",
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCustomSelected = true;
                    });
                  },
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCustomSelected ? Colors.orange : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange),
                        SizedBox(width: 5),
                        Text(
                          "Custom",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isCustomSelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.straighten, color: Colors.orange),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enter Custom Length",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Length must be between 20 to 60 feet",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: lengthController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: "35",
                            border: InputBorder.none,
                          ),
                          onChanged: _updateCustomLength,
                          onSubmitted: _validateCustomLength,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              "Quantity (ton)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        if ((cart[widget.itemName] ?? 0) > 1) {
                          cart[widget.itemName] = cart[widget.itemName]! - 1;
                        }
                      });
                      await saveCart();
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "${cart[widget.itemName] ?? 0}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        cart[widget.itemName] =
                            (cart[widget.itemName] ?? 0) + 1;
                      });
                      await saveCart();
                    },
                    child: const Icon(Icons.add, color: Colors.orange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
