class AcademyNotice {
  const AcademyNotice({
    this.id,
    required this.title,
    required this.body,
    required this.date,
    this.important = false,
  });
  final int? id;
  final String title, body, date;
  final bool important;
  factory AcademyNotice.fromMap(Map<String, Object?> m) => AcademyNotice(
    id: m['id'] as int?,
    title: m['title'] as String,
    body: m['body'] as String,
    date: m['date'] as String,
    important: (m['important'] as int) == 1,
  );
  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'date': date,
    'important': important ? 1 : 0,
  };
}
