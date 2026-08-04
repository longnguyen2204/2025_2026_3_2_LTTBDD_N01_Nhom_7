/// Đại diện cho một từ vựng trong bộ từ.
class Word {
  final String id;
  String term; // Từ tiếng Anh
  String meaning; // Nghĩa tiếng Việt
  String? phonetic; // Phiên âm (tùy chọn)
  String? example; // Ví dụ minh họa (tùy chọn)
  bool isLearned; // Đã thuộc hay chưa
  bool isFavorite; // Đã đánh dấu yêu thích hay chưa

  Word({
    required this.id,
    required this.term,
    required this.meaning,
    this.phonetic,
    this.example,
    this.isLearned = false,
    this.isFavorite = false,
  });

  /// Đảo trạng thái đã thuộc / chưa thuộc.
  void toggleLearned() {
    isLearned = !isLearned;
  }

  /// Đảo trạng thái yêu thích của từ.
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
