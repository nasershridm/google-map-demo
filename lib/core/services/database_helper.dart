import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dndn/core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable SQLite foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table: trips
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        total_distance REAL DEFAULT 0.0,
        duration_seconds INTEGER DEFAULT 0,
        average_speed REAL DEFAULT 0.0,
        max_speed REAL DEFAULT 0.0,
        point_count INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    // Table: location_points
    await db.execute('''
      CREATE TABLE location_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        speed REAL DEFAULT 0.0,
        accuracy REAL DEFAULT 0.0,
        altitude REAL DEFAULT 0.0,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    // Table: incident_reports (شرطة - حادث - زحام)
    await db.execute('''
      CREATE TABLE incident_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // Indices for optimized querying
    await db.execute(
      'CREATE INDEX idx_location_points_trip_id ON location_points (trip_id)',
    );
    await db.execute(
      'CREATE INDEX idx_location_points_timestamp ON location_points (timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_trips_start_time ON trips (start_time DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_incident_reports_timestamp ON incident_reports (timestamp DESC)',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
