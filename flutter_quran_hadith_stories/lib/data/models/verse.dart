class Verse {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String textAr;

  const Verse({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textAr,
  });

  factory Verse.fromMap(Map<String, Object?> row) {
    return Verse(
      id: row['id'] as int,
      surahId: row['surah_id'] as int,
      ayahNumber: row['ayah_number'] as int,
      textAr: row['text_ar'] as String,
    );
  }
}