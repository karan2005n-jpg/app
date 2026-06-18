import 'package:flutter/material.dart';

import 'package:dealer/screens/auth/customize.dart';

class Homepageorder extends StatefulWidget {
  final String id;
  final int quantity;
  final VoidCallback onAdd;
  final Future<void> Function() onUpdated;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final String name;
  final String imagePath;
  final String title;
  final String subtitle;
  final IconData? icon;
  final String stockdata;
  final String price;
  final String imagedata;

  const Homepageorder({
    super.key,

    required this.name,
    required this.id,
    required this.quantity,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
    required this.imagePath,
    required this.onUpdated,
    this.icon,
    required this.subtitle,
    required this.title,
    required this.stockdata,
    required this.price,
    required this.imagedata,
  });

  @override
  State<Homepageorder> createState() => _HomepageorderState();
}

class _HomepageorderState extends State<Homepageorder> {
  @override
  Widget build(BuildContext context) {
    bool isAdded = widget.quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.imagePath,
                  height: 100,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 5,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.imagedata,
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      widget.stockdata,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        isAdded
                            ? Container(
                                height: 26,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: widget.onDecrease,
                                      child: const Icon(Icons.remove, size: 15),
                                    ),
                                    const SizedBox(width: 10),
                                    Text("${widget.quantity}"),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: widget.onIncrease,
                                      child: const Icon(
                                        Icons.add,
                                        size: 15,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: const Size(0, 25),
                                ),
                                onPressed: widget.onAdd,
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),

                        const SizedBox(width: 5),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 12, color: Colors.orange),
                              GestureDetector(
                                onTap: () async {
                                   await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    constraints: BoxConstraints(
                                      maxWidth: double.infinity,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Customize(
                                      imagePath: 'assets/images/homepage.jpeg',
                                      itemName: widget.title,
                                    ),
                                    
                                  );
                                  
                                    await widget.onUpdated();
                                    setState(() {});
                                  
                                },
                                child: Text(
                                  "Customize",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.price,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          "per ton",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
