import 'package:flutter/material.dart';

class BuildInputField extends StatefulWidget {
  final String? hintText;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;

  const BuildInputField({
    super.key,
    this.hintText,
    this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<BuildInputField> createState() => _BuildInputFieldState();
}

class _BuildInputFieldState extends State<BuildInputField> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE9E3E3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? isHidden : false,

        style: const TextStyle(fontSize: 14, color: Colors.black87),

        decoration: InputDecoration(
          hintText: widget.hintText,

          hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      isHidden = !isHidden;
                    });
                  },
                  icon: Icon(
                    isHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                )
              : widget.icon != null
              ? Icon(widget.icon, size: 15, color: Colors.grey)
              : null,
        ),
      ),
    );
  }
}
