import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Học từ vựng Flashcard'**
  String get appTitle;

  /// No description provided for @decks.
  ///
  /// In vi, this message translates to:
  /// **'Bộ từ vựng'**
  String get decks;

  /// No description provided for @study.
  ///
  /// In vi, this message translates to:
  /// **'Học'**
  String get study;

  /// No description provided for @quiz.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra'**
  String get quiz;

  /// No description provided for @statistics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get about;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get add;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// No description provided for @finish.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get finish;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get english;

  /// No description provided for @deckListTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bộ từ vựng của tôi'**
  String get deckListTitle;

  /// No description provided for @emptyDeckList.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bộ từ vựng nào.\nNhấn nút + để tạo bộ từ đầu tiên.'**
  String get emptyDeckList;

  /// No description provided for @createDeck.
  ///
  /// In vi, this message translates to:
  /// **'Tạo bộ từ mới'**
  String get createDeck;

  /// No description provided for @editDeck.
  ///
  /// In vi, this message translates to:
  /// **'Sửa tên bộ từ'**
  String get editDeck;

  /// No description provided for @deckName.
  ///
  /// In vi, this message translates to:
  /// **'Tên bộ từ'**
  String get deckName;

  /// No description provided for @deckNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Giao tiếp hằng ngày'**
  String get deckNameHint;

  /// No description provided for @deckNameEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Tên bộ từ không được để trống'**
  String get deckNameEmpty;

  /// No description provided for @deleteDeckTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ từ vựng'**
  String get deleteDeckTitle;

  /// No description provided for @deleteDeckMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa bộ từ \"{name}\" và toàn bộ từ vựng bên trong?'**
  String deleteDeckMessage(String name);

  /// No description provided for @deckCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo bộ từ mới'**
  String get deckCreated;

  /// No description provided for @deckUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật bộ từ'**
  String get deckUpdated;

  /// No description provided for @deckDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bộ từ'**
  String get deckDeleted;

  /// No description provided for @wordCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count} từ'**
  String wordCountLabel(int count);

  /// No description provided for @learnedProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đã thuộc {learned}/{total}'**
  String learnedProgress(int learned, int total);

  /// No description provided for @wordListTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách từ vựng'**
  String get wordListTitle;

  /// No description provided for @emptyWordList.
  ///
  /// In vi, this message translates to:
  /// **'Bộ từ này chưa có từ vựng nào.\nNhấn nút + để thêm từ đầu tiên.'**
  String get emptyWordList;

  /// No description provided for @addWord.
  ///
  /// In vi, this message translates to:
  /// **'Thêm từ mới'**
  String get addWord;

  /// No description provided for @editWord.
  ///
  /// In vi, this message translates to:
  /// **'Sửa từ vựng'**
  String get editWord;

  /// No description provided for @wordTerm.
  ///
  /// In vi, this message translates to:
  /// **'Từ tiếng Anh'**
  String get wordTerm;

  /// No description provided for @wordMeaning.
  ///
  /// In vi, this message translates to:
  /// **'Nghĩa tiếng Việt'**
  String get wordMeaning;

  /// No description provided for @wordPhonetic.
  ///
  /// In vi, this message translates to:
  /// **'Phiên âm (tùy chọn)'**
  String get wordPhonetic;

  /// No description provided for @wordExample.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ minh họa (tùy chọn)'**
  String get wordExample;

  /// No description provided for @wordTermEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập từ tiếng Anh'**
  String get wordTermEmpty;

  /// No description provided for @wordMeaningEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập nghĩa tiếng Việt'**
  String get wordMeaningEmpty;

  /// No description provided for @deleteWordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa từ vựng'**
  String get deleteWordTitle;

  /// No description provided for @deleteWordMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa từ \"{term}\"?'**
  String deleteWordMessage(String term);

  /// No description provided for @wordAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm từ mới'**
  String get wordAdded;

  /// No description provided for @wordUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật từ vựng'**
  String get wordUpdated;

  /// No description provided for @wordDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa từ vựng'**
  String get wordDeleted;

  /// No description provided for @searchWords.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm từ vựng'**
  String get searchWords;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @filterLearned.
  ///
  /// In vi, this message translates to:
  /// **'Đã thuộc'**
  String get filterLearned;

  /// No description provided for @filterNotLearned.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thuộc'**
  String get filterNotLearned;

  /// No description provided for @filterFavorite.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get filterFavorite;

  /// No description provided for @sortTermAsc.
  ///
  /// In vi, this message translates to:
  /// **'A → Z'**
  String get sortTermAsc;

  /// No description provided for @sortTermDesc.
  ///
  /// In vi, this message translates to:
  /// **'Z → A'**
  String get sortTermDesc;

  /// No description provided for @sortLearnedFirst.
  ///
  /// In vi, this message translates to:
  /// **'Đã thuộc trước'**
  String get sortLearnedFirst;

  /// No description provided for @sortUnlearnedFirst.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thuộc trước'**
  String get sortUnlearnedFirst;

  /// No description provided for @noSearchResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy từ nào phù hợp'**
  String get noSearchResults;

  /// No description provided for @studyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Học flashcard'**
  String get studyTitle;

  /// No description provided for @emptyDeckForStudy.
  ///
  /// In vi, this message translates to:
  /// **'Bộ từ chưa có từ vựng, vui lòng thêm từ trước khi học'**
  String get emptyDeckForStudy;

  /// No description provided for @tapToFlip.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào thẻ để xem nghĩa'**
  String get tapToFlip;

  /// No description provided for @swipeHint.
  ///
  /// In vi, this message translates to:
  /// **'Vuốt sang trái/phải để chuyển thẻ'**
  String get swipeHint;

  /// No description provided for @markLearned.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu đã thuộc'**
  String get markLearned;

  /// No description provided for @markNotLearned.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu chưa thuộc'**
  String get markNotLearned;

  /// No description provided for @learned.
  ///
  /// In vi, this message translates to:
  /// **'Đã thuộc'**
  String get learned;

  /// No description provided for @notLearned.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thuộc'**
  String get notLearned;

  /// No description provided for @cardPosition.
  ///
  /// In vi, this message translates to:
  /// **'{current}/{total}'**
  String cardPosition(int current, int total);

  /// No description provided for @studyFinished.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã học hết bộ từ này!'**
  String get studyFinished;

  /// No description provided for @quizTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bài kiểm tra'**
  String get quizTitle;

  /// No description provided for @notEnoughWords.
  ///
  /// In vi, this message translates to:
  /// **'Bộ từ cần có ít nhất 4 từ để tạo bài kiểm tra'**
  String get notEnoughWords;

  /// No description provided for @questionPosition.
  ///
  /// In vi, this message translates to:
  /// **'Câu {current}/{total}'**
  String questionPosition(int current, int total);

  /// No description provided for @chooseQuizType.
  ///
  /// In vi, this message translates to:
  /// **'Chọn hình thức làm bài'**
  String get chooseQuizType;

  /// No description provided for @quizTypeMultipleChoice.
  ///
  /// In vi, this message translates to:
  /// **'Trắc nghiệm'**
  String get quizTypeMultipleChoice;

  /// No description provided for @quizTypeMultipleChoiceDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chọn 1 trong 4 đáp án'**
  String get quizTypeMultipleChoiceDesc;

  /// No description provided for @quizTypeTyping.
  ///
  /// In vi, this message translates to:
  /// **'Điền từ'**
  String get quizTypeTyping;

  /// No description provided for @quizTypeTypingDesc.
  ///
  /// In vi, this message translates to:
  /// **'Gõ nghĩa tiếng Việt của từ'**
  String get quizTypeTypingDesc;

  /// No description provided for @typingAnswerHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập nghĩa tiếng Việt...'**
  String get typingAnswerHint;

  /// No description provided for @checkAnswer.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra'**
  String get checkAnswer;

  /// No description provided for @answerCorrect.
  ///
  /// In vi, this message translates to:
  /// **'Chính xác!'**
  String get answerCorrect;

  /// No description provided for @answerIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đúng'**
  String get answerIncorrect;

  /// No description provided for @startQuiz.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get startQuiz;

  /// No description provided for @questionPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nghĩa đúng của từ:'**
  String get questionPrompt;

  /// No description provided for @typingPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Nhập nghĩa tiếng Việt của từ:'**
  String get typingPrompt;

  /// No description provided for @checkAnswerFirst.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng bấm Kiểm tra trước khi tiếp tục'**
  String get checkAnswerFirst;

  /// No description provided for @nextQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Câu tiếp theo'**
  String get nextQuestion;

  /// No description provided for @submitQuiz.
  ///
  /// In vi, this message translates to:
  /// **'Nộp bài'**
  String get submitQuiz;

  /// No description provided for @selectAnswerFirst.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn một đáp án'**
  String get selectAnswerFirst;

  /// No description provided for @comboLabel.
  ///
  /// In vi, this message translates to:
  /// **'Combo x{count}'**
  String comboLabel(int count);

  /// No description provided for @feedbackCorrect1.
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt vời!'**
  String get feedbackCorrect1;

  /// No description provided for @feedbackCorrect2.
  ///
  /// In vi, this message translates to:
  /// **'Chính xác!'**
  String get feedbackCorrect2;

  /// No description provided for @feedbackCorrect3.
  ///
  /// In vi, this message translates to:
  /// **'Giỏi lắm!'**
  String get feedbackCorrect3;

  /// No description provided for @feedbackIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đúng, thử lại nhé'**
  String get feedbackIncorrect;

  /// No description provided for @quizResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả kiểm tra'**
  String get quizResultTitle;

  /// No description provided for @yourScore.
  ///
  /// In vi, this message translates to:
  /// **'Điểm của bạn'**
  String get yourScore;

  /// No description provided for @correctCount.
  ///
  /// In vi, this message translates to:
  /// **'Đúng {correct}/{total} câu'**
  String correctCount(int correct, int total);

  /// No description provided for @reviewAnswers.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại đáp án'**
  String get reviewAnswers;

  /// No description provided for @yourAnswer.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chọn:'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In vi, this message translates to:
  /// **'Đáp án đúng:'**
  String get correctAnswer;

  /// No description provided for @notAnswered.
  ///
  /// In vi, this message translates to:
  /// **'Chưa trả lời'**
  String get notAnswered;

  /// No description provided for @retakeQuiz.
  ///
  /// In vi, this message translates to:
  /// **'Làm lại'**
  String get retakeQuiz;

  /// No description provided for @backToDeck.
  ///
  /// In vi, this message translates to:
  /// **'Về bộ từ'**
  String get backToDeck;

  /// No description provided for @historyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử làm bài'**
  String get historyTitle;

  /// No description provided for @emptyHistory.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lượt làm bài nào'**
  String get emptyHistory;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa toàn bộ lịch sử làm bài?'**
  String get clearHistoryMessage;

  /// No description provided for @historyCleared.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa lịch sử'**
  String get historyCleared;

  /// No description provided for @statisticsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê tiến độ'**
  String get statisticsTitle;

  /// No description provided for @totalDecks.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số bộ từ'**
  String get totalDecks;

  /// No description provided for @totalWords.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số từ vựng'**
  String get totalWords;

  /// No description provided for @totalLearned.
  ///
  /// In vi, this message translates to:
  /// **'Số từ đã thuộc'**
  String get totalLearned;

  /// No description provided for @overallProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ tổng thể'**
  String get overallProgress;

  /// No description provided for @progressByDeck.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ theo từng bộ từ'**
  String get progressByDeck;

  /// No description provided for @emptyStatistics.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu để thống kê'**
  String get emptyStatistics;

  /// No description provided for @quizzesCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Bài đã làm'**
  String get quizzesCompleted;

  /// No description provided for @averageScore.
  ///
  /// In vi, this message translates to:
  /// **'Điểm trung bình'**
  String get averageScore;

  /// No description provided for @profilesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profilesTitle;

  /// No description provided for @addProfile.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hồ sơ'**
  String get addProfile;

  /// No description provided for @profileName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hồ sơ'**
  String get profileName;

  /// No description provided for @profileNameEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Tên hồ sơ không được để trống'**
  String get profileNameEmpty;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa hồ sơ'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa hồ sơ \"{name}\"? Toàn bộ bộ từ và lịch sử của hồ sơ này sẽ mất.'**
  String deleteProfileMessage(String name);

  /// No description provided for @cannotDeleteLastProfile.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa hồ sơ cuối cùng'**
  String get cannotDeleteLastProfile;

  /// No description provided for @activeProfileLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng'**
  String get activeProfileLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @interfaceLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ giao diện'**
  String get interfaceLanguage;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @aboutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin nhóm'**
  String get aboutTitle;

  /// No description provided for @projectName.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng học từ vựng Anh – Việt bằng Flashcard'**
  String get projectName;

  /// No description provided for @subjectName.
  ///
  /// In vi, this message translates to:
  /// **'Lập trình cho thiết bị di động'**
  String get subjectName;

  /// No description provided for @universityName.
  ///
  /// In vi, this message translates to:
  /// **'Trường Đại học Phenikaa'**
  String get universityName;

  /// No description provided for @groupLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm 7 – Lớp N01'**
  String get groupLabel;

  /// No description provided for @instructorLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giảng viên hướng dẫn'**
  String get instructorLabel;

  /// No description provided for @membersLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên nhóm'**
  String get membersLabel;

  /// No description provided for @instructorName.
  ///
  /// In vi, this message translates to:
  /// **'Nguyễn Xuân Quế'**
  String get instructorName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
