class QuizzesRaw {
  final int count;
  final List<QuizRaw> items;

  QuizzesRaw({
    required this.count,
    required this.items,
  });

  bool get isAllDone => items.every((quiz) => quiz.isDone);

  factory QuizzesRaw.fromJson(Map<String, dynamic> json, List<int> doneIds) {
    return QuizzesRaw(
      count: json['count'] as int,
      items: (json['items'] as List).map((item) => QuizRaw.fromJson(item, doneIds)).toList(),
    );
  }
}

class QuizRaw {
  final int id;
  final String question;
  final List<String> options;
  final bool isDone;

  QuizRaw({
    required this.id,
    required this.question,
    required this.options,
    required this.isDone,
  });

  factory QuizRaw.fromJson(Map<String, dynamic> json, List<int> doneIds) {
    return QuizRaw(id: json['id'] as int, question: json['question'] as String, options: List<String>.from(json['options'] as List), isDone: doneIds.contains(json['id'] as int));
  }

  QuizRaw copyWith({
    int? id,
    String? question,
    List<String>? options,
    bool? isDone,
  }) {
    return QuizRaw(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      isDone: isDone ?? this.isDone,
    );
  }
}
