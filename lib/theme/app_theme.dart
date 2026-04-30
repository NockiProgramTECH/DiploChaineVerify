import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFB32128); // Darker red from mockup
  static const Color primaryGreen = Color(0xFF007A33); // Darker green from mockup
  static const Color accentGold = Color(0xFFFFD700);
  static const Color backgroundLight = Color(0xFFF9F7F2); // Off-white/beige background
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textLight = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        primary: AppColors.primaryRed,
        secondary: AppColors.primaryGreen,
        background: AppColors.backgroundLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static TextStyle bodyText = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textDark,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.grey,
  );
}
