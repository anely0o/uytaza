import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';

enum RoundButtonType { primary, secondary, line }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? lineColor;
  final double width;
  final double radius;
  final VoidCallback onPressed;

  const RoundButton({
    super.key,
    required this.title,
    this.type = RoundButtonType.primary,
    this.height = 60,
    this.fontSize = 17,
    this.fontWeight = FontWeight.normal,
    this.width = double.maxFinite,
    this.lineColor,
    this.radius = 30,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: switch (type) {
            RoundButtonType.primary   => TColor.primary,
            RoundButtonType.secondary => TColor.secondary,
            RoundButtonType.line      => Colors.transparent,
          },
          borderRadius: BorderRadius.circular(radius),
          border: type == RoundButtonType.line
              ? Border.all(color: lineColor ?? TColor.primary, width: 2)
              : null,
          boxShadow: [
            if (type != RoundButtonType.line)
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
      ),
    );
  }
}
