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

  // Hadiths with pagination
  Future<List<Hadith>> getHadiths({int limit = 50, int offset = 0, String? collection}) async {
    final db = await _db;
    final rows = await db.query(
      'hadiths',
      where: collection != null ? 'collection = ?' : null,
      whereArgs: collection != null ? [collection] : null,
      orderBy: 'CAST(number AS INT) ASC, id ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => Hadith.fromMap(e)).toList();
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

  // Unified Search across tafsir, hadiths, stories
  Future<Map<String, List<Map<String, Object?>>>> searchAll(String query, {int limitPerSection = 20}) async {
    final db = await _db;
    final likeQuery = '%$query%';

    final tafsirRows = await db.rawQuery(
      'SELECT t.id, t.verse_id, v.surah_id, s.name_ar AS surah_name, t.source, t.text AS content '\
      'FROM tafsir t JOIN verses v ON v.id = t.verse_id JOIN surahs s ON s.id = v.surah_id '\
      'WHERE t.text LIKE ? LIMIT ?',
      [likeQuery, limitPerSection],
    );

    final hadithRows = await db.rawQuery(
      'SELECT h.id, h.collection, h.book, h.number, h.text_ar AS content, h.grade FROM hadiths h WHERE h.text_ar LIKE ? OR h.sanad LIKE ? LIMIT ?',
      [likeQuery, likeQuery, limitPerSection],
    );

    final storyRows = await db.rawQuery(
      'SELECT s.id, s.prophet, s.title, s.content FROM stories s WHERE s.title LIKE ? OR s.content LIKE ? LIMIT ?',
      [likeQuery, likeQuery, limitPerSection],
    );

    return {
      'tafsir': tafsirRows,
      'hadiths': hadithRows,
      'stories': storyRows,
    };
  }
}