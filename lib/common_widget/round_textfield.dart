import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';

class RoundTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final double radius;
  final bool obscureText;
  final Widget? right;
  final bool isPadding;

  const RoundTextfield({
    super.key,
    required this.hintText,
    this.controller,
    this.radius = 25,
    this.obscureText = false,
    this.right,
    this.isPadding = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: isPadding ? 20 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: TColor.divider.withOpacity(1.0),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        obscureText: obscureText,
        style: TextStyle(color: TColor.textPrimary, fontSize: 17),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          suffixIcon: right,
          hintStyle: TextStyle(color: TColor.placeholder, fontSize: 17),
        ),
      ),
    );
  }
}

class NewRoundTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final double radius;
  final bool obscureText;
  final Widget? right;
  final bool isPadding;

  const NewRoundTextfield({
    super.key,
    required this.hintText,
    this.controller,
    this.radius = 25,
    this.obscureText = false,
    this.right,
    this.isPadding = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: isPadding ? 20 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: TColor.softShadow,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        obscureText: obscureText,
        style: TextStyle(color: TColor.textPrimary, fontSize: 17),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          suffixIcon: right,
          hintStyle: TextStyle(color: TColor.placeholder, fontSize: 17),
        ),
      ),
    );
  }
}
