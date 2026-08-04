import 'quiz_type.dart';

class QuizHistory {
  final String id;
  final String deckName;
  final int score;
  final int totalQuestions;
  final QuizType quizType;
  final DateTime timestamp;

  QuizHistory({
    required this.id,
    required this.deckName,
    required this.score,
    required this.totalQuestions,
    required this.quizType,
    required this.timestamp,
  });
}
