import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';

enum RoundButtonType { primary, secondary, line }

class RoundButton extends StatelessWidget {
  final String title;

  /// If you explicitly pass a backgroundColor, it will override the type-based default.
  final Color? backgroundColor;

  /// If you explicitly pass a textColor, it will override the type-based default.
  final Color? textColor;

  /// Only used if [type] == RoundButtonType.line
  final Color? lineColor;

  final RoundButtonType type;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double width;
  final double radius;
  final VoidCallback onPressed;

  const RoundButton({
    super.key,
    required this.title,
    this.type = RoundButtonType.primary,
    this.backgroundColor,
    this.textColor,
    this.lineColor,
    this.height = 60,
    this.fontSize = 17,
    this.fontWeight = FontWeight.normal,
    this.width = double.maxFinite,
    this.radius = 30,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine default background + text colors based on `type`
    Color defaultBackground;
    Color defaultText;
    BorderSide? borderSide;

    switch (type) {
      case RoundButtonType.primary:
        defaultBackground = TColor.primary;
        defaultText = Colors.white;
        break;
      case RoundButtonType.secondary:
        defaultBackground = TColor.accent; // rare yellow
        defaultText = Colors.white;
        break;
      case RoundButtonType.line:
        defaultBackground = Colors.transparent;
        defaultText = lineColor ?? TColor.primary;
        borderSide = BorderSide(color: lineColor ?? TColor.primary, width: 2);
        break;
    }

    // If the user passed explicit backgroundColor / textColor, use those instead
    final Color finalBg = backgroundColor ?? defaultBackground;
    final Color finalText = textColor ?? defaultText;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: finalBg,
          border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
          borderRadius: BorderRadius.circular(radius),
        ),
        height: height,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: finalText,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
