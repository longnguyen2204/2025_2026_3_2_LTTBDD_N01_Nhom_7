import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/deck.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_type.dart';
import '../models/word.dart';

/// Quản lý một bài trắc nghiệm: sinh câu hỏi ngẫu nhiên từ bộ từ vựng,
/// ghi nhận đáp án người dùng chọn và chấm điểm.
class QuizProvider extends ChangeNotifier {
  /// Số từ tối thiểu trong bộ để tạo được bài trắc nghiệm
  /// (1 đáp án đúng + 3 đáp án nhiễu).
  static const int minWordsRequired = 4;

  /// Số đáp án của mỗi câu hỏi.
  static const int optionCount = 4;

  final List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  final Map<String, String> _userAnswers = {};

  final Random _random = Random();

  List<QuizQuestion> get questions => List.unmodifiable(_questions);
  int get currentIndex => _currentIndex;
  Map<String, String> get userAnswers => Map.unmodifiable(_userAnswers);

  /// Tổng số câu hỏi của bài trắc nghiệm hiện tại.
  int get totalQuestions => _questions.length;

  /// Câu hỏi đang hiển thị, null nếu chưa sinh câu hỏi.
  QuizQuestion? get currentQuestion {
    if (_currentIndex < 0 || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  /// Đáp án người dùng đã chọn cho câu hỏi hiện tại (null nếu chưa chọn).
  String? get currentAnswer {
    final question = currentQuestion;
    if (question == null) return null;
    return _userAnswers[question.id];
  }

  /// Sinh bài trắc nghiệm từ bộ từ vựng được chọn.
  /// Trả về true nếu tạo thành công, false nếu bộ từ không đủ số từ tối thiểu.
  bool generateQuiz(Deck deck) {
    if (deck.words.length < minWordsRequired) return false;

    _questions.clear();
    _userAnswers.clear();
    _currentIndex = 0;

    // Xáo trộn thứ tự từ để tránh học vẹt theo thứ tự trong bộ.
    final shuffledWords = List<Word>.from(deck.words)..shuffle(_random);

    for (var i = 0; i < shuffledWords.length; i++) {
      final word = shuffledWords[i];
      _questions.add(
        QuizQuestion(
          id: 'q_${i + 1}',
          word: word,
          options: _buildOptions(word, deck.words),
          correctAnswer: word.meaning,
          type: QuizType.multipleChoice,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  /// Tạo danh sách đáp án cho một câu hỏi:
  /// 1 đáp án đúng (nghĩa của từ) + 3 đáp án nhiễu lấy từ các từ khác trong bộ.
  List<String> _buildOptions(Word word, List<Word> allWords) {
    final distractors =
        allWords
            .where((w) => w.id != word.id && w.meaning != word.meaning)
            .map((w) => w.meaning)
            .toSet()
            .toList()
          ..shuffle(_random);

    final options = <String>[word.meaning];
    for (final meaning in distractors) {
      if (options.length >= optionCount) break;
      options.add(meaning);
    }

    // Xáo trộn để đáp án đúng không luôn nằm ở vị trí đầu tiên.
    options.shuffle(_random);
    return options;
  }

  /// Ghi nhận đáp án người dùng chọn cho một câu hỏi.
  void submitAnswer(String questionId, String answer) {
    _userAnswers[questionId] = answer;
    notifyListeners();
  }

  /// Còn câu hỏi tiếp theo hay không.
  bool hasNext() {
    return _currentIndex < _questions.length - 1;
  }

  /// Chuyển sang câu hỏi kế tiếp (nếu còn).
  void nextQuestion() {
    if (hasNext()) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Quay lại câu hỏi trước đó (nếu có).
  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Chấm điểm và trả về kết quả bài trắc nghiệm.
  QuizResult calculateResult() {
    var correct = 0;
    for (final question in _questions) {
      final answer = _userAnswers[question.id];
      if (answer != null && question.isCorrect(answer)) {
        correct++;
      }
    }

    return QuizResult(
      totalQuestions: _questions.length,
      correctAnswers: correct,
      questions: List<QuizQuestion>.from(_questions),
      userAnswers: Map<String, String>.from(_userAnswers),
    );
  }

  /// Xóa trạng thái bài trắc nghiệm hiện tại.
  void resetQuiz() {
    _questions.clear();
    _userAnswers.clear();
    _currentIndex = 0;
    notifyListeners();
  }
}
