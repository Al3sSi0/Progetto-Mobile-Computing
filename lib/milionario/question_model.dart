class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final int difficulty;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
  });

  
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'] ?? '',
      options: List<String>.from(map['options']),
      correctIndex: map['correct_index'] ?? 0,
      difficulty: map['difficulty'] ?? 1,
    );
  }
}