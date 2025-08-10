class Surah {
  final int id;
  final String nameAr;

  const Surah({required this.id, required this.nameAr});

  factory Surah.fromMap(Map<String, Object?> row) {
    return Surah(
      id: row['id'] as int,
      nameAr: row['name_ar'] as String,
    );
  }
}