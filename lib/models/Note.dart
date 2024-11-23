class Note {
  final String id;
  String title;
  String content;
  String date;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  // Преобразование в Map для Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
  }

  // Создание объекта Note из данных Firebase
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
    );
  }
}
