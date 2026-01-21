class AppConstants {
  static const String apiBaseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Endpoints
  static const String searchEndpoint = '$apiBaseUrl/search.php';
  static const String filterEndpoint = '$apiBaseUrl/filter.php';
  static const String lookupEndpoint = '$apiBaseUrl/lookup.php';
  static const String categoriesEndpoint = '$apiBaseUrl/categories.php';
  static const String listEndpoint = '$apiBaseUrl/list.php';

  // Database
  static const String dbName = 'recipe_finder.db';
  static const String favoritesTableName = 'favorites';
}
