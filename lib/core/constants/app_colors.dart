import 'package:flutter/material.dart';


class AppColors {
  AppColors._();

  static const Color primaryDark = Color(
    0xFF0F172A,
  ); 
  static const Color primaryLight = Color(
    0xFF1E293B,
  ); 

 
  static const Color successGreen = Color(
    0xFF16A34A,
  ); 
  static const Color warningAmber = Color(
    0xFFF59E0B,
  ); 
  static const Color dangerRed = Color(0xFFEF4444); // Red 500 - delete, expired


  static const Color bgLight = Color(0xFFF9FAFB); // Gray 50 - main background
  static const Color cardBg = Colors.white; // White - card backgrounds
  static const Color surfaceBg = Color(
    0xFFF1F5F9,
  ); 


  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textMuted = Color(0xFF9CA3AF); // Gray 400
  static const Color textOnDark = Colors.white;


  static const Color borderLight = Color(0xFFE5E7EB); // Gray 200
  static const Color borderMedium = Color(0xFFD1D5DB); // Gray 300


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


  static Color getMatchColor(int percentage) {
    if (percentage >= 100) return successGreen;
    if (percentage >= 70) return warningAmber;
    return textMuted;
  }
}
