import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF5F7FB);
  static const card = Colors.white;
  static const primary = Color.fromARGB(255, 151, 156, 238); // soft indigo
   static const primaryDark = Color.fromARGB(255, 64, 65, 100);
  static const accent = Color(0xFFA5D8FF); // soft blue
  static const textMain = Color(0xFF1C1C1E);
  static const textSoft = Color(0xFF8A8A8E);
  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    letterSpacing: -0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
    fontWeight: FontWeight.w400,
  );
}

class AppStyles {
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  static const subtitle = TextStyle(fontSize: 16, color: AppColors.textSoft);
}