import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF8E8E8E);
  static const Color lightGrey = Color(0xFFDBDBDB);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  static const Color heartRed = Color(0xFFFF0000);
  static const Color linkBlue = Color(0xFF0057B8);

  static const Color storyGradientStart = Color(0xFFFCCC63);
  static const Color storyGradientMid = Color(0xFFFBAD50);
  static const Color storyGradientEnd = Color(0xFFC32AA3);

  static const List<Color> storyGradient = [
    storyGradientStart,
    storyGradientMid,
    storyGradientEnd,
    storyGradientStart,
  ];
}
