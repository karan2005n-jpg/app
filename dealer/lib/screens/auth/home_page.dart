import 'package:dealer/screens/auth/addtoCart.dart';
import 'package:dealer/widgets/homepageicon.dart';
import 'package:dealer/widgets/homepageorder.dart';
import 'package:dealer/widgets/notification_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> cart = {};
  int totalAmount = 0;

  List products = [];

  @override
  void initState() {
    super.initState();
    loadCart();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:3001/products/products"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          products = data;
        });
      } else {
        debugPrint("ERROR: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("cart", jsonEncode(cart));
    await prefs.setInt("amount", totalAmount);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    String? cartString = prefs.getString("cart");

    setState(() {
      if (cartString != null) {
        cart = Map<String, int>.from(jsonDecode(cartString));
      }

      totalAmount = prefs.getInt("amount") ?? 0;
    });
  }

  int get totalitems => cart.values.fold(0, (sum, q) => sum + q);

  void updateTotal() {
    totalAmount = 0;

    for (var item in products) {
      String name = item["product_name"];
      int qty = cart[name] ?? 0;
      int price = int.parse(item["unit_price_per_ton"].toString());

      totalAmount += qty * price;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: totalitems > 0
          ? Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                color: Colors.black,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        color: Colors.orange,
                        child: Center(
                          child: Icon(Icons.shopping_cart_outlined, size: 10),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "SELECTED \n $totalitems tons",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const VerticalDivider(
                          color: Colors.white,
                          thickness: 1,
                        ),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Text(
                            "ESTIMATED TOTAL",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "INR $totalAmount",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: Size(double.infinity, 54),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addtocart(
                            totalAmount: totalAmount,
                            totalitems: totalitems,
                          ),
                        ),
                      );

                      await loadCart();

                      setState(() {
                        updateTotal();
                      });
                    },
                    child: Text(
                      "Proceed to Review ",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                height: 168,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/homepage.jpeg"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const Spacer(),
                          NotificationIcon(),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Create Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Select Products & Add to Your Cart",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    Homepageicon(icon: Icons.menu, data: "all products"),
                    SizedBox(width: 5),
                    Homepageicon(icon: Icons.menu, data: "tmt bars"),
                    SizedBox(width: 5),
                    Homepageicon(icon: Icons.menu, data: "angles"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              products.isEmpty
                  ? Center(child: CircularProgressIndicator(color: Colors.orange,))
                  : Column(
                      children: products.map((item) {
                        String productName = item["product_name"];
                        String productId = item["product_id"].toString();
                        String description = item["description"] ?? "";
                        int price = int.parse(
                          item["unit_price_per_ton"].toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Homepageorder(
                            onUpdated: () async {
                              await loadCart();
                              setState(() {updateTotal();});
                              await saveCart();
                            },
                            id: productId,
                            name: productName,
                            quantity: cart[productName] ?? 0,
                            onAdd: () async {
                              setState(() {
                                cart[productName] = 1;
                                updateTotal();
                              });
                              await saveCart();
                            },
                            onIncrease: () async {
                              setState(() {
                                cart[productName] =
                                    (cart[productName] ?? 0) + 1;
                                updateTotal();
                              });
                              await saveCart();
                            },
                            onDecrease: () async {
                              setState(() {
                                if (cart[productName] == 1) {
                                  cart.remove(productName);
                                } else {
                                  cart[productName] =
                                      cart[productName]! - 1;
                                }

                                updateTotal();
                              });
                              await saveCart();
                            },
                            imagePath: "assets/images/homepage.jpeg",
                            icon: Icons.check_box_outline_blank,
                            subtitle: description,
                            title: productName,
                            stockdata:
                                "INR ${(cart[productName] ?? 0) * price}",
                            price: "₹$price",
                            imagedata: productName,
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}