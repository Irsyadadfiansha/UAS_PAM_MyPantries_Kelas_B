/// API Constants for EaThink Mobile App
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  static const String baseUrl = 'http://api.paw2.eathink-mypantry.cloud';

  /// API prefix
  static const String apiPrefix = '/api';

  /// Full API base URL
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  /// Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String user = '/user';

  /// Pantry endpoints
  static const String pantry = '/pantry';
  static const String pantryExpiringSoon = '/pantry/expiring-soon';

  /// Recipe endpoints
  static const String recipes = '/recipes';
  static const String recipeRecommendations = '/recipes/recommendations';
  static const String recipesWithMatch = '/recipes/with-match';

  /// Ingredient endpoints
  static const String ingredients = '/ingredients';
  static const String ingredientCategories = '/ingredients/categories';

  /// Timeout settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
