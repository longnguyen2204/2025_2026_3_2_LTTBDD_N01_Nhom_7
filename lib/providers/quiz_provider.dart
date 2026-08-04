import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/deck.dart';
import '../models/quiz_history.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_type.dart';
import '../models/word.dart';
import '../repositories/history_repository.dart';

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

  final HistoryRepository _historyRepository = HistoryRepository();
  List<QuizHistory> _history = [];

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
  bool generateQuiz(Deck deck, QuizType type) {
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
          options: type == QuizType.multipleChoice
              ? _buildOptions(word, deck.words)
              : const [],
          correctAnswer: word.meaning,
          type: type,
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

  bool checkTypingAnswer(String questionId, String answer) {
    submitAnswer(questionId, answer);
    for (final question in _questions) {
      if (question.id == questionId) {
        return _isAnswerCorrect(question, answer);
      }
    }
    return false;
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

  String _normalize(String text) => text.trim().toLowerCase();

  bool _isAnswerCorrect(QuizQuestion question, String answer) {
    if (question.type == QuizType.typing) {
      return _normalize(answer) == _normalize(question.correctAnswer);
    }
    return question.isCorrect(answer);
  }

  /// Chấm điểm và trả về kết quả bài trắc nghiệm.
  QuizResult calculateResult() {
    var correct = 0;
    for (final question in _questions) {
      final answer = _userAnswers[question.id];
      if (answer != null && _isAnswerCorrect(question, answer)) {
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

  Future<void> loadHistory() async {
    _history = await _historyRepository.loadHistory();
    notifyListeners();
  }

  List<QuizHistory> getHistory() => List.unmodifiable(_history);

  Future<void> saveResult(
    String deckName,
    QuizResult result,
    QuizType type,
  ) async {
    final entry = QuizHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deckName: deckName,
      score: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      quizType: type,
      timestamp: DateTime.now(),
    );
    _history = [entry, ..._history];
    notifyListeners();
    await _historyRepository.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _historyRepository.saveHistory(_history);
  }
}
