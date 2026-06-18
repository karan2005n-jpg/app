import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final Color color;
  final String count;
  final IconData icon;
  final Color iconcolor;

  const StatCard({
    super.key,
    required this.title,
    required this.color,
    required this.count,
    required this.icon,
    required this.iconcolor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(icon, color: iconcolor),
            ],
          ),
        ],
      ),
    );
  }
}
