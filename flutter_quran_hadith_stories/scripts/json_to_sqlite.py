#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import sqlite3
from pathlib import Path

SCHEMA_SQL = r'''
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;

CREATE TABLE IF NOT EXISTS surahs (
  id INTEGER PRIMARY KEY,
  name_ar TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS verses (
  id INTEGER PRIMARY KEY,
  surah_id INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  text_ar TEXT NOT NULL,
  FOREIGN KEY (surah_id) REFERENCES surahs(id)
);

CREATE TABLE IF NOT EXISTS tafsir (
  id INTEGER PRIMARY KEY,
  verse_id INTEGER NOT NULL,
  source TEXT NOT NULL,
  text TEXT NOT NULL,
  FOREIGN KEY (verse_id) REFERENCES verses(id)
);

CREATE TABLE IF NOT EXISTS hadiths (
  id INTEGER PRIMARY KEY,
  collection TEXT NOT NULL,
  book TEXT NOT NULL,
  number TEXT NOT NULL,
  text_ar TEXT NOT NULL,
  sanad TEXT NOT NULL,
  grade TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS stories (
  id INTEGER PRIMARY KEY,
  prophet TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_verses_surah ON verses(surah_id, ayah_number);
CREATE INDEX IF NOT EXISTS idx_tafsir_verse ON tafsir(verse_id);
CREATE INDEX IF NOT EXISTS idx_hadiths_text ON hadiths(text_ar);
CREATE INDEX IF NOT EXISTS idx_stories_title ON stories(title);

-- FTS5 virtual tables for fast full-text search
CREATE VIRTUAL TABLE IF NOT EXISTS tafsir_fts USING fts5(text, content='');
CREATE VIRTUAL TABLE IF NOT EXISTS hadiths_fts USING fts5(text_ar, sanad, content='');
CREATE VIRTUAL TABLE IF NOT EXISTS stories_fts USING fts5(title, content, content='');
'''


def load_json(path: Path):
  with path.open('r', encoding='utf-8') as f:
    return json.load(f)


def import_tafsir(conn, tafsir_json: Path):
  data = load_json(tafsir_json)
  surahs = data.get('surahs', [])
  verses = data.get('verses', [])
  tafsir_list = data.get('tafsir', [])

  cur = conn.cursor()
  cur.executemany('INSERT OR REPLACE INTO surahs(id, name_ar) VALUES(?, ?)',
                  [(s['id'], s['name_ar']) for s in surahs])

  cur.executemany('''
    INSERT OR REPLACE INTO verses(id, surah_id, ayah_number, text_ar)
    VALUES(?, ?, ?, ?)
  ''', [(v['id'], v['surah_id'], v['ayah_number'], v['text_ar']) for v in verses])

  cur.executemany('''
    INSERT OR REPLACE INTO tafsir(id, verse_id, source, text)
    VALUES(?, ?, ?, ?)
  ''', [(t['id'], t['verse_id'], t['source'], t['text']) for t in tafsir_list])


def import_hadiths(conn, hadiths_json: Path):
  items = load_json(hadiths_json)
  cur = conn.cursor()
  cur.executemany('''
    INSERT OR REPLACE INTO hadiths(id, collection, book, number, text_ar, sanad, grade)
    VALUES(?, ?, ?, ?, ?, ?, ?)
  ''', [
    (h['id'], h['collection'], h['book'], h['number'], h['text_ar'], h['sanad'], h['grade'])
    for h in items
  ])


def import_stories(conn, stories_json: Path):
  items = load_json(stories_json)
  cur = conn.cursor()
  cur.executemany('''
    INSERT OR REPLACE INTO stories(id, prophet, title, content)
    VALUES(?, ?, ?, ?)
  ''', [
    (s['id'], s['prophet'], s['title'], s['content']) for s in items
  ])


def populate_fts(conn):
  cur = conn.cursor()
  # Clear existing
  cur.execute('DELETE FROM tafsir_fts')
  cur.execute('DELETE FROM hadiths_fts')
  cur.execute('DELETE FROM stories_fts')
  # Populate with rowid aligned to base table ids
  cur.execute('INSERT INTO tafsir_fts(rowid, text) SELECT id, text FROM tafsir')
  cur.execute('INSERT INTO hadiths_fts(rowid, text_ar, sanad) SELECT id, text_ar, sanad FROM hadiths')
  cur.execute('INSERT INTO stories_fts(rowid, title, content) SELECT id, title, content FROM stories')


def main():
  parser = argparse.ArgumentParser(description='Convert JSON datasets to a single SQLite database (knowledge.db).')
  parser.add_argument('--tafsir', type=Path, default=Path('assets/json/tafsir_sample.json'))
  parser.add_argument('--hadiths', type=Path, default=Path('assets/json/ahadith_sample.json'))
  parser.add_argument('--stories', type=Path, default=Path('assets/json/stories_sample.json'))
  parser.add_argument('--out', type=Path, default=Path('assets/databases/knowledge.db'))
  args = parser.parse_args()

  out_path: Path = args.out
  out_path.parent.mkdir(parents=True, exist_ok=True)

  conn = sqlite3.connect(str(out_path))
  try:
    conn.executescript(SCHEMA_SQL)
    if args.tafsir and args.tafsir.exists():
      import_tafsir(conn, args.tafsir)
    if args.hadiths and args.hadiths.exists():
      import_hadiths(conn, args.hadiths)
    if args.stories and args.stories.exists():
      import_stories(conn, args.stories)
    populate_fts(conn)
    conn.commit()
    print(f"SQLite database created at: {out_path}")
  finally:
    conn.close()


if __name__ == '__main__':
  main()