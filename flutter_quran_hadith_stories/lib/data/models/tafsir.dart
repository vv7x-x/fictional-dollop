class Tafsir {
  final int id;
  final int verseId;
  final String source;
  final String text;

  const Tafsir({
    required this.id,
    required this.verseId,
    required this.source,
    required this.text,
  });

  factory Tafsir.fromMap(Map<String, Object?> row) {
    return Tafsir(
      id: row['id'] as int,
      verseId: row['verse_id'] as int,
      source: row['source'] as String,
      text: row['text'] as String,
    );
  }
}