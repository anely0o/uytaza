import 'package:flutter/material.dart';




class TColor {
  static Color get primary => const Color(0xFF2979FF);       // основной синий
  static Color get secondary => const Color(0xFFFDD835);     // мягкий жёлтый (для акцентов)
  static Color get background => const Color(0xFFF9FBFD);    // общий фон
  static Color get card => const Color(0xFFFFFFFF);          // карточки
  static Color get shadow => const Color(0x1A000000);        // лёгкая тень
  static Color get divider => const Color(0xFFE0E0E0);       // разделители
  static Color get chatTextBG => const Color(0xFFF9FBFD);
  static Color get chatTextBG2 => const Color(0xFFFFFFFF);

  static Color get title => const Color(0xFF1B1E23);
  static Color get primaryText => const Color(0xFF1B1E23);   // текст основной
  static Color get secondaryText => const Color(0xFF607D8B); // текст второстепенный
  static Color get placeholder => const Color(0xFFB0BEC5);   // текст-подсказка

  static Color get success => const Color(0xFF81C784);       // зелёный
  static Color get error => const Color(0xFFE57373);         // красный
}



extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
