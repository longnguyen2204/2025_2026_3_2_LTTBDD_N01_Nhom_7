import 'package:flutter/foundation.dart';

import '../models/deck.dart';
import '../models/word.dart';

/// Quản lý trạng thái của một phiên học flashcard:
/// bộ từ đang học và vị trí thẻ hiện tại.
class StudyProvider extends ChangeNotifier {
  Deck? _currentDeck;
  int _currentIndex = 0;

  Deck? get currentDeck => _currentDeck;
  int get currentIndex => _currentIndex;

  /// Danh sách từ của bộ đang học (rỗng nếu chưa bắt đầu phiên học).
  List<Word> get words => _currentDeck?.words ?? [];

  /// Từ vựng đang hiển thị trên thẻ hiện tại, null nếu không có.
  Word? get currentWord {
    if (_currentDeck == null || _currentDeck!.words.isEmpty) return null;
    if (_currentIndex < 0 || _currentIndex >= _currentDeck!.words.length) {
      return null;
    }
    return _currentDeck!.words[_currentIndex];
  }

  /// Tổng số thẻ trong phiên học.
  int get totalCards => words.length;

  /// Bắt đầu một phiên học mới với bộ từ được chọn.
  void startStudy(Deck deck) {
    _currentDeck = deck;
    _currentIndex = 0;
    notifyListeners();
  }

  /// Chuyển sang thẻ tiếp theo (nếu còn).
  void nextCard() {
    if (_currentDeck == null) return;
    if (_currentIndex < _currentDeck!.words.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Quay lại thẻ trước đó (nếu có).
  void previousCard() {
    if (_currentDeck == null) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Nhảy tới thẻ theo chỉ số — dùng khi người dùng vuốt bằng PageView.
  void goToCard(int index) {
    if (_currentDeck == null) return;
    if (index < 0 || index >= _currentDeck!.words.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Đảo trạng thái đã thuộc / chưa thuộc của một từ trong bộ đang học.
  void toggleLearned(String wordId) {
    if (_currentDeck == null) return;
    for (final word in _currentDeck!.words) {
      if (word.id == wordId) {
        word.toggleLearned();
        notifyListeners();
        return;
      }
    }
  }

  /// Đã học tới thẻ cuối cùng hay chưa.
  bool isFinished() {
    if (_currentDeck == null || _currentDeck!.words.isEmpty) return true;
    return _currentIndex >= _currentDeck!.words.length - 1;
  }

  /// Kết thúc phiên học, xóa trạng thái hiện tại.
  void endStudy() {
    _currentDeck = null;
    _currentIndex = 0;
    notifyListeners();
  }
}
