class Story {
  final int id;
  final String prophet;
  final String title;
  final String content;

  const Story({
    required this.id,
    required this.prophet,
    required this.title,
    required this.content,
  });

  factory Story.fromMap(Map<String, Object?> row) {
    return Story(
      id: row['id'] as int,
      prophet: row['prophet'] as String,
      title: row['title'] as String,
      content: row['content'] as String,
    );
  }
}