import 'package:dealer/screens/auth/addtoCart.dart';
import 'package:dealer/widgets/homepageicon.dart';
import 'package:dealer/widgets/homepageorder.dart';
import 'package:dealer/widgets/notification_button.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dealer/provider/cart_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List products = [];

  @override
  void initState() {
    super.initState();
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

        if (mounted) {
          context.read<CartProvider>().updateTotal(products);
        }
      } else {
        debugPrint("ERROR: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      bottomNavigationBar: cartProvider.totalItems > 0
          ? Container(
              height: 120,
              decoration: const BoxDecoration(
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
                        child: const Center(
                          child: Icon(Icons.shopping_cart_outlined, size: 10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "SELECTED \n ${cartProvider.totalItems} tons",
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
                      const Spacer(),
                      Column(
                        children: [
                          const Text(
                            "ESTIMATED TOTAL",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "INR ${cartProvider.totalAmount}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addtocart(
                            totalAmount: cartProvider.totalAmount,
                            totalitems: cartProvider.totalItems,
                          ),
                        ),
                      );

                      if (mounted) {
                        await context.read<CartProvider>().loadCart();
                        context.read<CartProvider>().updateTotal(products);
                      }
                    },
                    child: const Text(
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
                    const Spacer(),
                    const Padding(
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
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
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
                              await cartProvider.loadCart();
                              cartProvider.updateTotal(products);
                            },
                            id: productId,
                            name: productName,
                            quantity: cartProvider.cart[productName] ?? 0,
                            onAdd: () async {
                              await cartProvider.addItem(productName, products);
                            },
                            onIncrease: () async {
                              await cartProvider.increaseItem(
                                productName,
                                products,
                              );
                            },
                            onDecrease: () async {
                              await cartProvider.decreaseItem(
                                productName,
                                products,
                              );
                            },
                            imagePath: "assets/images/homepage.jpeg",
                            icon: Icons.check_box_outline_blank,
                            subtitle: description,
                            title: productName,
                            stockdata:
                                "INR ${(cartProvider.cart[productName] ?? 0) * price}",
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
