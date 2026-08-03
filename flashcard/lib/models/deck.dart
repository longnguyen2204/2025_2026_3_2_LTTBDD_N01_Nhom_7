import 'word.dart';

/// Đại diện cho một bộ từ vựng, chứa danh sách các Word.
class Deck {
  final String id;
  String name;
  List<Word> words;

  Deck({required this.id, required this.name, List<Word>? words})
    : words = words ?? [];

  /// Thêm một từ vựng mới vào bộ từ.
  void addWord(Word word) {
    words.add(word);
  }

  /// Cập nhật thông tin một từ vựng đã có trong bộ (theo id).
  void updateWord(Word updatedWord) {
    final index = words.indexWhere((w) => w.id == updatedWord.id);
    if (index != -1) {
      words[index] = updatedWord;
    }
  }

  /// Xóa một từ vựng khỏi bộ theo id.
  void removeWord(String id) {
    words.removeWhere((w) => w.id == id);
  }

  /// Tổng số từ vựng trong bộ.
  int wordCount() => words.length;

  /// Số từ đã được đánh dấu "đã thuộc".
  int learnedCount() => words.where((w) => w.isLearned).length;
}
