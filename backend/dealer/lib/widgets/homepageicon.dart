import 'package:flutter/material.dart';

class Homepageicon extends StatelessWidget {
  final IconData icon;
  final String data;
  const Homepageicon({super.key, required this.icon, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 53,
          width: 53,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),

          child: Center(child: Icon(icon)),
        ),

        Text(data, style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
