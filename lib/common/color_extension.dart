import 'package:flutter/material.dart';

class TColor {


  static Color get primary => const Color(0xFF8AD1FF);       // темно-синий (#1C2C53)
  static Color get secondary => const Color(0xFFF4BF7D);     // персиковый (#F4BF7D)
  static Color get background => const Color(0xFFFEFEFE);    // белый фон (#FEFEFE)
  static Color get card => const Color(0xFFFFEDDF);          // карточки (чистый белый)
  static Color get shadow => const Color(0x1A000000);        // лёгкая тень
  static Color get divider => const Color(0xFFEBECEE);       // разделители (#EBECEE)
  static Color get bg => const Color(0xFFF1F8FE);           // светло-голубой (#8AD1FF)
  static Color get primaryText => const Color(0xFF1C2C53);   // текст основной (темно-синий)
  static Color get secondaryText => const Color(0xFF607D8B); // текст второстепенный
  static Color get placeholder => const Color(0xFFB0BEC5);   // текст-подсказка
  static Color get title => const Color(0xFF1C2C53);         // заголовки (темно-синий)

  static Color get success => const Color(0xFF81C784);       // зелёный
  static Color get error => const Color(0xFFE57373);         // красный
  static Color get chatTextBG => const Color(0xff115173);
  static Color get chatTextBG2 => const Color(0xffF4F6FF);
  static Color get border => const Color(0xFF607D8B);
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