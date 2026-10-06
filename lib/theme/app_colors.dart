import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundDark = Color(0xFF0B1320); // Very dark navy
  static const Color backgroundLight = Color(0xFF0E1726);

  // Cards and Panels
  static const Color cardColor = Color(0xFF16243A);
  static const Color cardColorLight = Color(0xFF1C2C45);

  // Accents
  static const Color primaryYellow = Color(0xFFFFB300); // Amber/Yellow
  static const Color primaryYellowDark = Color(0xFFE6A200);

  // Text
  static const Color textWhite = Colors.white;
  static const Color textGray = Color(0xFF8B9CB6);

  // Status Colors
  static const Color statusAvailable = Color(0xFFFFB300); // Yellow
  static const Color statusPending = Color(0xFF8B9CB6); // Gray

  // Team Accents
  static const List<Color> teamColors = [
    Color(0xFF1E88E5), // Blue
    Color(0xFFFFB300), // Amber
    Color(0xFF43A047), // Green
    Color(0xFFE53935), // Red
    Color(0xFFFB8C00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFF00ACC1), // Cyan
    Color(0xFFD81B60), // Pink
    Color(0xFF00897B), // Teal
    Color(0xFF3949AB), // Indigo
    Color(0xFF7CB342), // Light Green
    Color(0xFFF4511E), // Deep Orange
  ];

  static Color getTeamColor(int index) {
    if (index < 0) return teamColors[0];
    if (index < teamColors.length) return teamColors[index];

    // For teams beyond our hand-picked palette (12+), generate unique colors
    // using the Golden Angle (approx 137.5 degrees) for maximum distribution on the hue wheel.
    final double hue = (index * 137.508) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.75, 0.6).toColor();
  }
}
