import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryYellow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryYellow,
        secondary: AppColors.primaryYellowDark,
        surface: AppColors.cardColor,
      ),
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(color: AppColors.textWhite),
          bodyMedium: const TextStyle(color: AppColors.textGray),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryYellow),
        titleTextStyle: TextStyle(
          color: AppColors.primaryYellow,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        unselectedItemColor: AppColors.textGray,
        selectedItemColor: AppColors.primaryYellow,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
}
