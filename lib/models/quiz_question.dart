import 'quiz_type.dart';
import 'word.dart';

/// Đại diện cho một câu hỏi trắc nghiệm được sinh ra từ một Word.
class QuizQuestion {
  final String id;
  final Word word; // Từ vựng gốc của câu hỏi
  final List<String> options; // Danh sách 4 đáp án (1 đúng + 3 nhiễu)
  final String correctAnswer;
  final QuizType type; // Hình thức làm bài của câu hỏi

  QuizQuestion({
    required this.id,
    required this.word,
    required this.options,
    required this.correctAnswer,
    required this.type,
  });

  /// Kiểm tra đáp án người dùng chọn có đúng không.
  bool isCorrect(String answer) {
    return answer == correctAnswer;
  }
}
