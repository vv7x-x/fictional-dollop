class Hadith {
  final int id;
  final String collection; // e.g., البخاري
  final String book;       // book/chapter
  final String number;     // hadith number
  final String textAr;
  final String sanad;
  final String grade;      // صحيح، حسن، ضعيف

  const Hadith({
    required this.id,
    required this.collection,
    required this.book,
    required this.number,
    required this.textAr,
    required this.sanad,
    required this.grade,
  });

  factory Hadith.fromMap(Map<String, Object?> row) {
    return Hadith(
      id: row['id'] as int,
      collection: row['collection'] as String,
      book: row['book'] as String,
      number: row['number'] as String,
      textAr: row['text_ar'] as String,
      sanad: row['sanad'] as String,
      grade: row['grade'] as String,
    );
  }
}