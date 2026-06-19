import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String? imagePath;
  final IconData? icon;

  const SocialButton({super.key, this.imagePath, this.icon});

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (imagePath != null) {
      child = Image.asset(
        imagePath!,
        height: 12,
        width: 12,
        fit: BoxFit.contain,
      );
    } else {
      child = Icon(icon, size: 12, color: Colors.black87);
    }

    return Container(
      height: 36,
      width: 47,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Center(child: child),
    );
  }
}
