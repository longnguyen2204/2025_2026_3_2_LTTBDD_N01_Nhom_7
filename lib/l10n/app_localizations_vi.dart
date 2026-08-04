// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Học từ vựng Flashcard';

  @override
  String get decks => 'Bộ từ vựng';

  @override
  String get study => 'Học';

  @override
  String get quiz => 'Kiểm tra';

  @override
  String get statistics => 'Thống kê';

  @override
  String get settings => 'Cài đặt';

  @override
  String get about => 'Giới thiệu';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Sửa';

  @override
  String get add => 'Thêm';

  @override
  String get close => 'Đóng';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get back => 'Quay lại';

  @override
  String get finish => 'Hoàn thành';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get deckListTitle => 'Bộ từ vựng của tôi';

  @override
  String get emptyDeckList =>
      'Chưa có bộ từ vựng nào.\nNhấn nút + để tạo bộ từ đầu tiên.';

  @override
  String get createDeck => 'Tạo bộ từ mới';

  @override
  String get editDeck => 'Sửa tên bộ từ';

  @override
  String get deckName => 'Tên bộ từ';

  @override
  String get deckNameHint => 'Ví dụ: Giao tiếp hằng ngày';

  @override
  String get deckNameEmpty => 'Tên bộ từ không được để trống';

  @override
  String get deleteDeckTitle => 'Xóa bộ từ vựng';

  @override
  String deleteDeckMessage(String name) {
    return 'Bạn có chắc muốn xóa bộ từ \"$name\" và toàn bộ từ vựng bên trong?';
  }

  @override
  String get deckCreated => 'Đã tạo bộ từ mới';

  @override
  String get deckUpdated => 'Đã cập nhật bộ từ';

  @override
  String get deckDeleted => 'Đã xóa bộ từ';

  @override
  String wordCountLabel(int count) {
    return '$count từ';
  }

  @override
  String learnedProgress(int learned, int total) {
    return 'Đã thuộc $learned/$total';
  }

  @override
  String get wordListTitle => 'Danh sách từ vựng';

  @override
  String get emptyWordList =>
      'Bộ từ này chưa có từ vựng nào.\nNhấn nút + để thêm từ đầu tiên.';

  @override
  String get addWord => 'Thêm từ mới';

  @override
  String get editWord => 'Sửa từ vựng';

  @override
  String get wordTerm => 'Từ tiếng Anh';

  @override
  String get wordMeaning => 'Nghĩa tiếng Việt';

  @override
  String get wordPhonetic => 'Phiên âm (tùy chọn)';

  @override
  String get wordExample => 'Ví dụ minh họa (tùy chọn)';

  @override
  String get wordTermEmpty => 'Vui lòng nhập từ tiếng Anh';

  @override
  String get wordMeaningEmpty => 'Vui lòng nhập nghĩa tiếng Việt';

  @override
  String get deleteWordTitle => 'Xóa từ vựng';

  @override
  String deleteWordMessage(String term) {
    return 'Bạn có chắc muốn xóa từ \"$term\"?';
  }

  @override
  String get wordAdded => 'Đã thêm từ mới';

  @override
  String get wordUpdated => 'Đã cập nhật từ vựng';

  @override
  String get wordDeleted => 'Đã xóa từ vựng';

  @override
  String get searchWords => 'Tìm kiếm từ vựng';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterLearned => 'Đã thuộc';

  @override
  String get filterNotLearned => 'Chưa thuộc';

  @override
  String get filterFavorite => 'Yêu thích';

  @override
  String get sortTermAsc => 'A → Z';

  @override
  String get sortTermDesc => 'Z → A';

  @override
  String get sortLearnedFirst => 'Đã thuộc trước';

  @override
  String get sortUnlearnedFirst => 'Chưa thuộc trước';

  @override
  String get noSearchResults => 'Không tìm thấy từ nào phù hợp';

  @override
  String get studyTitle => 'Học flashcard';

  @override
  String get emptyDeckForStudy =>
      'Bộ từ chưa có từ vựng, vui lòng thêm từ trước khi học';

  @override
  String get tapToFlip => 'Chạm vào thẻ để xem nghĩa';

  @override
  String get swipeHint => 'Vuốt sang trái/phải để chuyển thẻ';

  @override
  String get markLearned => 'Đánh dấu đã thuộc';

  @override
  String get markNotLearned => 'Đánh dấu chưa thuộc';

  @override
  String get learned => 'Đã thuộc';

  @override
  String get notLearned => 'Chưa thuộc';

  @override
  String cardPosition(int current, int total) {
    return '$current/$total';
  }

  @override
  String get studyFinished => 'Bạn đã học hết bộ từ này!';

  @override
  String get quizTitle => 'Bài kiểm tra';

  @override
  String get notEnoughWords => 'Bộ từ cần có ít nhất 4 từ để tạo bài kiểm tra';

  @override
  String questionPosition(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String get questionPrompt => 'Chọn nghĩa đúng của từ:';

  @override
  String get nextQuestion => 'Câu tiếp theo';

  @override
  String get submitQuiz => 'Nộp bài';

  @override
  String get selectAnswerFirst => 'Vui lòng chọn một đáp án';

  @override
  String get quizResultTitle => 'Kết quả kiểm tra';

  @override
  String get yourScore => 'Điểm của bạn';

  @override
  String correctCount(int correct, int total) {
    return 'Đúng $correct/$total câu';
  }

  @override
  String get reviewAnswers => 'Xem lại đáp án';

  @override
  String get yourAnswer => 'Bạn chọn:';

  @override
  String get correctAnswer => 'Đáp án đúng:';

  @override
  String get notAnswered => 'Chưa trả lời';

  @override
  String get retakeQuiz => 'Làm lại';

  @override
  String get backToDeck => 'Về bộ từ';

  @override
  String get statisticsTitle => 'Thống kê tiến độ';

  @override
  String get totalDecks => 'Tổng số bộ từ';

  @override
  String get totalWords => 'Tổng số từ vựng';

  @override
  String get totalLearned => 'Số từ đã thuộc';

  @override
  String get overallProgress => 'Tiến độ tổng thể';

  @override
  String get progressByDeck => 'Tiến độ theo từng bộ từ';

  @override
  String get emptyStatistics => 'Chưa có dữ liệu để thống kê';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get interfaceLanguage => 'Ngôn ngữ giao diện';

  @override
  String get aboutTitle => 'Thông tin nhóm';

  @override
  String get projectName => 'Ứng dụng học từ vựng Anh – Việt bằng Flashcard';

  @override
  String get subjectName => 'Lập trình cho thiết bị di động';

  @override
  String get universityName => 'Trường Đại học Phenikaa';

  @override
  String get groupLabel => 'Nhóm 7 – Lớp N01';

  @override
  String get instructorLabel => 'Giảng viên hướng dẫn';

  @override
  String get membersLabel => 'Thành viên nhóm';

  @override
  String get instructorName => 'Nguyễn Xuân Quế';
}
