import 'package:intl/intl.dart';

/// Date utility functions
class AppDateUtils {
  AppDateUtils._();

  /// Format date to display string (dd MMM yyyy)
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id').format(date);
  }

  /// Format date to short display (dd/MM/yyyy)
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date for API (yyyy-MM-dd)
  static String formatForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse date from API
  static DateTime? parseFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get days until expiry
  static int daysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  /// Check if expiring within days
  static bool isExpiringSoon(DateTime expiryDate, {int withinDays = 7}) {
    final days = daysUntilExpiry(expiryDate);
    return days >= 0 && days <= withinDays;
  }

  /// Check if expired
  static bool isExpired(DateTime expiryDate) {
    return daysUntilExpiry(expiryDate) < 0;
  }

  /// Get expiry text
  static String getExpiryText(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);
    if (days < 0) {
      return 'Kadaluarsa';
    } else if (days == 0) {
      return 'Hari ini';
    } else if (days == 1) {
      return '1 hari lagi';
    } else {
      return '$days hari lagi';
    }
  }
}
