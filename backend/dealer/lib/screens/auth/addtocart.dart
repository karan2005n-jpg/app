import 'package:dealer/screens/auth/home_page.dart';
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Addtocart extends StatefulWidget {
  final int totalitems;
  final int totalAmount;

  const Addtocart({
    super.key,
    required this.totalAmount,
    required this.totalitems,
  });

  @override
  State<Addtocart> createState() => _AddtocartState();
}

class _AddtocartState extends State<Addtocart> {
  Map<String, int> cart = {};
  Map<String, int> priceMap = {};

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

        Map<String, int> tempPriceMap = {};

        for (var item in data) {
          tempPriceMap[item["product_name"]] =
              int.parse(item["unit_price_per_ton"].toString());
        }

        setState(() {
          priceMap = tempPriceMap;
        });
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  int get totalAmount => cart.entries.fold(0, (sum, item) {
        return sum + (item.value * (priceMap[item.key] ?? 0));
      });

  int get totalitems => cart.values.fold(0, (sum, q) => sum + q);

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    String? cartString = prefs.getString("cart");

    if (cartString != null) {
      setState(() {
        cart = Map<String, int>.from(jsonDecode(cartString));
      });
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("cart", jsonEncode(cart));
    await prefs.setInt("amount", totalAmount);
  }

  Future<void> confirmOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      List<Map<String, dynamic>> cartItems = [];

      cart.forEach((key, value) {
        cartItems.add({
          "product_id": 1,
          "qty": value,
          "unit_price_per_ton": priceMap[key] ?? 0,
          "weight_ton": value,
          "product_name": key,
        });
      });

      final response = await http.post(
        Uri.parse("http://localhost:3001/orders/orders"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "dealer_id": userId,
          "estimated_total": totalAmount,
          "created_by": userId,
          "updated_by": userId,
          "cart": cartItems,
          "product_name": cart.keys.toList().first,
          "weight_ton": totalitems,
        }),
      );

      debugPrint("ORDER RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade100,
              title: const Text("Order Confirmed!"),
              content: const Text("Your order has been placed successfully."),
              actions: [
                TextButton(
                  onPressed: () async {
                    await prefs.remove("cart");

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order Failed: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint("ORDER ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server Error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Review Order",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Check your items and confirm",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 15),
                DottedLine(),
                SizedBox(height: 15),

                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.deepOrange),
                          color: const Color.fromARGB(0, 10, 17, 40),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.receipt_outlined,
                            size: 20,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "$totalitems ITEMS\n$totalitems tons",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Container(
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: VerticalDivider(
                          color: Color.fromARGB(0, 165, 144, 25),
                          thickness: 1,
                        ),
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ESTIMATED TOTAL",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "₹ $totalAmount",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 5),

                Row(
                  children: [
                    Text("Order Items"),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Edit Order",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    Icon(Icons.mode_edit_outlined, color: Colors.orange),
                  ],
                ),

                SizedBox(height: 10),

                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: cart.entries.map((item) {
                    int price = priceMap[item.key] ?? 0;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/homepage.jpeg",
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "₹ $price per ton",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          cart.remove(item.key);
                                        });
                                        await saveCart();
                                      },
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 28,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              setState(() {
                                                if (cart[item.key] == 1) {
                                                  cart.remove(item.key);
                                                } else {
                                                  cart[item.key] =
                                                      cart[item.key]! - 1;
                                                }
                                              });
                                              await saveCart();
                                            },
                                            child: Icon(Icons.remove, size: 18),
                                          ),
                                          SizedBox(width: 10),
                                          Text("${item.value}"),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () async {
                                              setState(() {
                                                cart[item.key] =
                                                    cart[item.key]! + 1;
                                              });
                                              await saveCart();
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Text("TOTAL :"),
                                    Text(
                                      " INR ${(cart[item.key] ?? 0) * price}",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromARGB(0, 142, 91, 24),
                        border: Border.all(color: Colors.yellow),
                      ),
                      child: Icon(Icons.receipt_outlined, color: Colors.orange),
                    ),
                    Text("Order Summary"),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.view_in_ar, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Total items"),
                    Spacer(),
                    Text("$totalitems"),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.work_outline, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Total Weight"),
                    Spacer(),
                    Text("$totalitems ton"),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Sub Total"),
                    Spacer(),
                    Text("₹ $totalAmount"),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Delivery Charges"),
                    Spacer(),
                    Text("₹ 0.00", style: TextStyle(color: Colors.green)),
                  ],
                ),

                SizedBox(height: 10),

                GestureDetector(
                  onTap: confirmOrder,
                  child: Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/cart.svg",
                          height: 30,
                          width: 30,
                        ),
                        Text(
                          "Confirm Order",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.arrow_right_alt, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}