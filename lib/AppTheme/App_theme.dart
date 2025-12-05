import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Black & Gold/Yellow Theme
  static const Color primaryBlack = Color(0xFF0D0D0D);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color cardBlack = Color(0xFF141414);
  static const Color surfaceBlack = Color(0xFF1E1E1E);

  // Accent Colors - Gold/Yellow
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color accentGold = Color(0xFFF5C518);
  static const Color lightGold = Color(0xFFFFE55C);
  static const Color darkGold = Color(0xFFB8860B);

  // Gradient Colors
  static const Color gradientStart = Color(0xFFFFD700);
  static const Color gradientEnd = Color(0xFFFF8C00);

  // Signal Colors
  static const Color buyGreen = Color(0xFF00E676);
  static const Color sellRed = Color(0xFFFF5252);
  static const Color waitOrange = Color(0xFFFFAB40);
  static const Color neutralGray = Color(0xFF757575);

  // Chart Colors
  static const Color candleGreen = Color(0xFF26A69A);
  static const Color candleRed = Color(0xFFEF5350);
  static const Color volumeBlue = Color(0xFF42A5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Glassmorphism
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGold, AppColors.gradientEnd],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFA500),
      Color(0xFFFFD700),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF0D0D0D),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E1E1E),
      Color(0xFF141414),
    ],
  );

  static LinearGradient buyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.buyGreen.withOpacity(0.8),
      AppColors.buyGreen.withOpacity(0.4),
    ],
  );

  static LinearGradient sellGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.sellRed.withOpacity(0.8),
      AppColors.sellRed.withOpacity(0.4),
    ],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBlack,
      primaryColor: AppColors.primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        secondary: AppColors.accentGold,
        surface: AppColors.surfaceBlack,
        error: AppColors.error,
        onPrimary: AppColors.primaryBlack,
        onSecondary: AppColors.primaryBlack,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGold,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBlack,
        elevation: 8,
        shadowColor: AppColors.primaryGold.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.rajdhani(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGold,
          letterSpacing: 1.2,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.primaryBlack,
          elevation: 8,
          shadowColor: AppColors.primaryGold.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGold,
          side: const BorderSide(color: AppColors.primaryGold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceBlack,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.rajdhani(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.rajdhani(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.primaryGold,
        suffixIconColor: AppColors.primaryGold,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBlack,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: GoogleFonts.rajdhani(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 11,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.primaryBlack,
        elevation: 8,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryGold,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.primaryGold.withOpacity(0.2),
        thickness: 1,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardBlack,
        contentTextStyle: GoogleFonts.rajdhani(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBlack,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGold,
        ),
        contentTextStyle: GoogleFonts.rajdhani(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceBlack,
        selectedColor: AppColors.primaryGold,
        disabledColor: AppColors.surfaceBlack,
        labelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
          color: AppColors.primaryBlack,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGold,
        circularTrackColor: AppColors.surfaceBlack,
        linearTrackColor: AppColors.surfaceBlack,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryGold,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primaryGold,
        labelStyle: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12,
        ),
      ),
    );
  }
}

// Custom Decorations
class AppDecorations {
  static BoxDecoration get glassCard => BoxDecoration(
    color: AppColors.glassWhite,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.glassBorder),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryGold.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration get goldBorderCard => BoxDecoration(
    color: AppColors.cardBlack,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.primaryGold.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryGold.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration get gradientCard => BoxDecoration(
    gradient: AppGradients.cardGradient,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.primaryGold.withOpacity(0.2),
      width: 1,
    ),
  );

  static BoxDecoration signalCard(String signal) {
    Color color;
    switch (signal.toUpperCase()) {
      case 'BUY':
        color = AppColors.buyGreen;
        break;
      case 'SELL':
        color = AppColors.sellRed;
        break;
      default:
        color = AppColors.waitOrange;
    }

    return BoxDecoration(
      color: AppColors.cardBlack,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.5), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}