import 'quiz_question.dart';

/// Đại diện cho kết quả của một bài trắc nghiệm đã hoàn thành.
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final List<QuizQuestion> questions;
  final Map<String, String>
  userAnswers; // key: questionId, value: đáp án đã chọn

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
    required this.userAnswers,
  });

  /// Điểm số dạng phần trăm (0.0 - 1.0).
  double score() {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// Lấy đáp án người dùng đã chọn cho một câu hỏi cụ thể.
  String? answerOf(String questionId) {
    return userAnswers[questionId];
  }
}
