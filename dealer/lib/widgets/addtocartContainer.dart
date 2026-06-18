import 'package:flutter/material.dart';

class AtcContainer extends StatelessWidget {
  final String length;
  final Color colores;
  final Color colors;
  final String data;

  const AtcContainer({
    super.key,
    required this.length,
    required this.colores,
    required this.colors,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: colores, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(length),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.withOpacity(0.1),
            ),
            child: Text(data, style: TextStyle(color: colors)),
          ),
        ],
      ),
    );
  }
}
