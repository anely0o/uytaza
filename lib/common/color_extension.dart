import 'package:flutter/material.dart';

class TColor {
  // Primary accent (blue)
  static Color get primary => const Color(0xFF1C2C53);        // Dark blue
  // Rare accent (yellow)
  static Color get accent => const Color(0xFFFFC107);         // Amber / Yellow
  // Neutral backgrounds
  static Color get background => const Color(0xFFF5F5F5);      // Very light grey
  static Color get card => Colors.white;                       // Cards remain white
  static Color get shadow => const Color(0x14000000);          // Very light shadow
  static Color get divider => const Color(0xFFEBECEE);         // Light grey divider
  // Text colors
  static Color get textPrimary => const Color(0xFF212121);     // Almost black
  static Color get textSecondary => const Color(0xFF757575);   // Medium grey
  static Color get placeholder => const Color(0xFFBDBDBD);     // Grey hint text
  static Color get title => const Color(0xFF1C2C53);           // Dark blue (same as primary)
  // Misc
  static List<BoxShadow> get softShadow => [
    const BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
