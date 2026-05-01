import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyBlue,
        primary: AppColors.navyBlue,
        secondary: AppColors.red,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.cuttingMatBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navyBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        titleLarge: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: AppColors.navyBlue,
        ),
        titleMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: AppColors.navyBlue,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.red,
        foregroundColor: AppColors.white,
      ),
    );
  }
}
