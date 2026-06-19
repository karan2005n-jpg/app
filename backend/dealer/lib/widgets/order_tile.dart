import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final String id;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;
  final Map<String, int> cart;

  const OrderTile({
    super.key,
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xff1e2a44),
            child: Icon(Icons.layers, color: Colors.white),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(date, style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 6),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cart.entries.map((e) {
                    return Text("${e.key} : ${e.value}");
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
