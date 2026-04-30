import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Burkina Faso flag colors
  static const Color primaryRed = Color(0xFFD21034);
  static const Color primaryGreen = Color(0xFF009A44);
  static const Color accentGold = Color(0xFFF7C948);

  // UI colors
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMedium = Color(0xFF4A4A6A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFF9F9F9);
  static const Color errorRed = Color(0xFFD21034);
  static const Color background = Color(0xFFFAF9F7);

  // Status colors
  static const Color authentic = Color(0xFF009A44);
  static const Color revoked = Color(0xFFD21034);
  static const Color unknown = Color(0xFFF7C948);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGold,
        error: AppColors.primaryRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }

  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
      );

  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
      );

  static TextStyle get labelBold => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );
}