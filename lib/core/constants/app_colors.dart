import 'package:flutter/material.dart';

/// App Color Palette for EaThink Mobile App
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryDark = Color(
    0xFF0F172A,
  ); // Slate 900 - header, buttons
  static const Color primaryLight = Color(
    0xFF1E293B,
  ); // Slate 800 - secondary elements

  // Semantic Colors
  static const Color successGreen = Color(
    0xFF16A34A,
  ); // Green 600 - "Siap Masak", can cook
  static const Color warningAmber = Color(
    0xFFF59E0B,
  ); // Amber 500 - expiring soon, partial match
  static const Color dangerRed = Color(0xFFEF4444); // Red 500 - delete, expired

  // Background Colors
  static const Color bgLight = Color(0xFFF9FAFB); // Gray 50 - main background
  static const Color cardBg = Colors.white; // White - card backgrounds
  static const Color surfaceBg = Color(
    0xFFF1F5F9,
  ); // Slate 100 - surface background

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textMuted = Color(0xFF9CA3AF); // Gray 400
  static const Color textOnDark = Colors.white;

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB); // Gray 200
  static const Color borderMedium = Color(0xFFD1D5DB); // Gray 300

  // Category Colors Map
  static const Map<String, Color> categoryColors = {
    'Protein': Color(0xFFFEE2E2), // Red 100
    'Sayuran': Color(0xFFDCFCE7), // Green 100
    'Susu': Color(0xFFDBEAFE), // Blue 100
    'Biji-Bijian': Color(0xFFFEF3C7), // Amber 100
    'Buah': Color(0xFFF3E8FF), // Purple 100
    'Bumbu & Saus': Color(0xFFFFEDD5), // Orange 100
    'Rempah': Color(0xFFFCE7F3), // Pink 100
    'Mineral': Color(0xFFE0F2FE), // Sky 100
  };

  // Category Icon Colors (darker for icon foreground)
  static const Map<String, Color> categoryIconColors = {
    'Protein': Color(0xFFDC2626), // Red 600
    'Sayuran': Color(0xFF16A34A), // Green 600
    'Susu': Color(0xFF2563EB), // Blue 600
    'Biji-Bijian': Color(0xFFD97706), // Amber 600
    'Buah': Color(0xFF9333EA), // Purple 600
    'Bumbu & Saus': Color(0xFFEA580C), // Orange 600
    'Rempah': Color(0xFFDB2777), // Pink 600
    'Mineral': Color(0xFF0284C7), // Sky 600
  };

  // Match Percentage Colors
  static Color getMatchColor(int percentage) {
    if (percentage >= 100) return successGreen;
    if (percentage >= 70) return warningAmber;
    return textMuted;
  }
}
