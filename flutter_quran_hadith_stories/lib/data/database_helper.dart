import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Provides a singleton SQLite database copied from assets on first launch.
/// Also exposes a method to refresh the database from assets for manual updates.
class DatabaseHelper {
  static const String _dbName = 'knowledge.db';
  static Database? _db;

  /// Returns an opened database instance. Copies the prebuilt DB on first access.
  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dbPath = await _ensureDatabaseReady();
    _db = await openDatabase(dbPath);
    return _db!;
  }

  /// Replaces the current local DB file with the packaged asset DB.
  /// Useful when you ship new data via an app update.
  static Future<void> refreshFromAssets() async {
    // Close if opened
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbFilePath = p.join(appDocDir.path, _dbName);
    final File dbFile = File(dbFilePath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    final ByteData data = await rootBundle.load('assets/databases/$_dbName');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await dbFile.create(recursive: true);
    await dbFile.writeAsBytes(bytes, flush: true);
  }

  static Future<String> _ensureDatabaseReady() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String dbFilePath = p.join(appDocDir.path, _dbName);

    final File dbFile = File(dbFilePath);
    if (!await dbFile.exists()) {
      await dbFile.create(recursive: true);
      final ByteData data = await rootBundle.load('assets/databases/$_dbName');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await dbFile.writeAsBytes(bytes, flush: true);
    }

    return dbFilePath;
  }
}