import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.favoritesTableName} (
        idStr TEXT PRIMARY KEY,
        strMeal TEXT,
        strCategory TEXT,
        strArea TEXT,
        strMealThumb TEXT,
        strInstructions TEXT,
        strYoutube TEXT,
        ingredients TEXT  -- JSON encoded list of ingredients
      )
    ''');
  }

  Future<int> insertFavorite(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(AppConstants.favoritesTableName, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeFavorite(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.favoritesTableName,
      where: 'idStr = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query(AppConstants.favoritesTableName);
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.favoritesTableName,
      where: 'idStr = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}
