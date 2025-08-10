import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _dbName = 'knowledge.db';
  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dbPath = await _ensureDatabaseReady();
    _db = await openDatabase(dbPath);
    return _db!;
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