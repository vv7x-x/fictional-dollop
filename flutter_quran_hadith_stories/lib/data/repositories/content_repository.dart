import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../models/tafsir.dart';
import '../models/hadith.dart';
import '../models/story.dart';

class ContentRepository {
  Future<Database> get _db async => DatabaseHelper.instance();

  // Surahs
  Future<List<Surah>> getSurahs({int limit = 114, int offset = 0}) async {
    final db = await _db;
    final rows = await db.query('surahs', limit: limit, offset: offset, orderBy: 'id ASC');
    return rows.map((e) => Surah.fromMap(e)).toList();
  }

  // Verses of a surah with optional pagination
  Future<List<Verse>> getVersesBySurah(int surahId, {int limit = 50, int offset = 0}) async {
    final db = await _db;
    final rows = await db.query(
      'verses',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_number ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => Verse.fromMap(e)).toList();
  }

  Future<Tafsir?> getTafsirForVerse(int verseId) async {
    final db = await _db;
    final rows = await db.query(
      'tafsir',
      where: 'verse_id = ?',
      whereArgs: [verseId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Tafsir.fromMap(rows.first);
  }

  // Hadiths with pagination and optional filters
  Future<List<Hadith>> getHadiths({int limit = 50, int offset = 0, String? collection, String? grade}) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];
    if (collection != null && collection.isNotEmpty && collection != 'الكل') {
      where.add('collection = ?');
      args.add(collection);
    }
    if (grade != null && grade.isNotEmpty && grade != 'الكل') {
      where.add('grade = ?');
      args.add(grade);
    }
    final rows = await db.query(
      'hadiths',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'CAST(number AS INT) ASC, id ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => Hadith.fromMap(e)).toList();
  }

  Future<List<String>> getHadithCollections() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT DISTINCT collection FROM hadiths ORDER BY collection');
    return rows.map((r) => r['collection'] as String).toList();
  }

  Future<List<String>> getHadithGrades() async {
    final db = await _db;
    final rows = await db.rawQuery('SELECT DISTINCT grade FROM hadiths ORDER BY grade');
    return rows.map((r) => r['grade'] as String).toList();
  }

  Future<Hadith?> getHadithById(int id) async {
    final db = await _db;
    final rows = await db.query('hadiths', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Hadith.fromMap(rows.first);
  }

  // Stories with pagination
  Future<List<Story>> getStories({int limit = 50, int offset = 0}) async {
    final db = await _db;
    final rows = await db.query('stories', orderBy: 'id ASC', limit: limit, offset: offset);
    return rows.map((e) => Story.fromMap(e)).toList();
  }

  Future<Story?> getStoryById(int id) async {
    final db = await _db;
    final rows = await db.query('stories', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Story.fromMap(rows.first);
  }

  // Unified Search across tafsir, hadiths, stories using FTS with fallback
  Future<Map<String, List<Map<String, Object?>>>> searchAll(String query, {int limitPerSection = 20}) async {
    final db = await _db;
    final likeQuery = '%$query%';

    List<Map<String, Object?>> tafsirRows;
    try {
      tafsirRows = await db.rawQuery(
        'SELECT t.id, t.verse_id, v.surah_id, s.name_ar AS surah_name, t.source, t.text AS content '
        'FROM tafsir t JOIN verses v ON v.id = t.verse_id JOIN surahs s ON s.id = v.surah_id '
        'JOIN tafsir_fts f ON f.rowid = t.id WHERE f.text MATCH ? LIMIT ?',
        [query, limitPerSection],
      );
    } catch (_) {
      tafsirRows = await db.rawQuery(
        'SELECT t.id, t.verse_id, v.surah_id, s.name_ar AS surah_name, t.source, t.text AS content '
        'FROM tafsir t JOIN verses v ON v.id = t.verse_id JOIN surahs s ON s.id = v.surah_id '
        'WHERE t.text LIKE ? LIMIT ?',
        [likeQuery, limitPerSection],
      );
    }

    List<Map<String, Object?>> hadithRows;
    try {
      hadithRows = await db.rawQuery(
        'SELECT h.id, h.collection, h.book, h.number, h.text_ar AS content, h.grade '
        'FROM hadiths h JOIN hadiths_fts f ON f.rowid = h.id WHERE hadiths_fts MATCH ? LIMIT ?',
        [query, limitPerSection],
      );
    } catch (_) {
      hadithRows = await db.rawQuery(
        'SELECT h.id, h.collection, h.book, h.number, h.text_ar AS content, h.grade FROM hadiths h WHERE h.text_ar LIKE ? OR h.sanad LIKE ? LIMIT ?',
        [likeQuery, likeQuery, limitPerSection],
      );
    }

    List<Map<String, Object?>> storyRows;
    try {
      storyRows = await db.rawQuery(
        'SELECT s.id, s.prophet, s.title, s.content FROM stories s JOIN stories_fts f ON f.rowid = s.id WHERE stories_fts MATCH ? LIMIT ?',
        [query, limitPerSection],
      );
    } catch (_) {
      storyRows = await db.rawQuery(
        'SELECT s.id, s.prophet, s.title, s.content FROM stories s WHERE s.title LIKE ? OR s.content LIKE ? LIMIT ?',
        [likeQuery, likeQuery, limitPerSection],
      );
    }

    return {
      'tafsir': tafsirRows,
      'hadiths': hadithRows,
      'stories': storyRows,
    };
  }
}