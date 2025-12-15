import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color secondaryBlue = Color(0xFF3F51B5);
  static const Color accentPink = Color(0xFFFF4081);
  
  // Dark theme colors
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceElevated = Color(0xFF16213E);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF3F51B5),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3F51B5),
      Color(0xFF2196F3),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF4081),
      Color(0xFFFF6B9D),
    ],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0xCC000000),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.7, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
    ],
  );
  
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A2A3E),
      Color(0xFF3A3A4E),
      Color(0xFF2A2A3E),
    ],
  );
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF808080);
  
  // Interactive colors
  static const Color interactivePrimary = Color(0xFF6C63FF);
  static const Color interactiveSecondary = Color(0xFF3F51B5);
  static const Color interactiveHover = Color(0xFF7C73FF);
  static const Color interactivePressed = Color(0xFF5C53EF);
  
  // Glassmorphism colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Success/Error colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  
  // Anime-specific mood colors
  static const LinearGradient romanceGradient = LinearGradient(
    colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
  );
  
  static const LinearGradient actionGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );
  
  static const LinearGradient fantasyGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );
  
  static const LinearGradient sliceOfLifeGradient = LinearGradient(
    colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
  );
  
  // Shadow colors
  static const Color shadowColor = Color(0x33000000);
  static const Color elevatedShadowColor = Color(0x26000000);
  
  // Border colors
  static const Color borderColor = Color(0x33FFFFFF);
  static const Color borderSecondary = Color(0x1AFFFFFF);
  
  // Helper methods for dynamic color selection
  static LinearGradient getMoodGradient(String genre) {
    switch (genre.toLowerCase()) {
      case 'romance':
      case 'shoujo':
        return romanceGradient;
      case 'action':
      case 'shounen':
        return actionGradient;
      case 'fantasy':
      case 'supernatural':
        return fantasyGradient;
      case 'slice of life':
      case 'comedy':
        return sliceOfLifeGradient;
      default:
        return cardGradient;
    }
  }
  
  static Color getMoodColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'romance':
      case 'shoujo':
        return Color(0xFFFF9A9E);
      case 'action':
      case 'shounen':
        return Color(0xFFFF6B6B);
      case 'fantasy':
      case 'supernatural':
        return Color(0xFF667eea);
      case 'slice of life':
      case 'comedy':
        return Color(0xFFa8edea);
      default:
        return primaryPurple;
    }
  }
}