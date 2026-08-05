// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flashcard Vocabulary';

  @override
  String get decks => 'Decks';

  @override
  String get study => 'Study';

  @override
  String get quiz => 'Quiz';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get deckListTitle => 'My Decks';

  @override
  String get emptyDeckList => 'No decks yet.\nTap + to create your first deck.';

  @override
  String get createDeck => 'Create new deck';

  @override
  String get editDeck => 'Rename deck';

  @override
  String get deckName => 'Deck name';

  @override
  String get deckNameHint => 'For example: Daily conversation';

  @override
  String get deckNameEmpty => 'Deck name cannot be empty';

  @override
  String get deleteDeckTitle => 'Delete deck';

  @override
  String deleteDeckMessage(String name) {
    return 'Are you sure you want to delete \"$name\" and all of its words?';
  }

  @override
  String get deckCreated => 'Deck created';

  @override
  String get deckUpdated => 'Deck updated';

  @override
  String get deckDeleted => 'Deck deleted';

  @override
  String wordCountLabel(int count) {
    return '$count words';
  }

  @override
  String learnedProgress(int learned, int total) {
    return 'Learned $learned/$total';
  }

  @override
  String get wordListTitle => 'Word list';

  @override
  String get emptyWordList =>
      'This deck has no words yet.\nTap + to add your first word.';

  @override
  String get addWord => 'Add new word';

  @override
  String get editWord => 'Edit word';

  @override
  String get wordTerm => 'English word';

  @override
  String get wordMeaning => 'Vietnamese meaning';

  @override
  String get wordPhonetic => 'Phonetic (optional)';

  @override
  String get wordExample => 'Example sentence (optional)';

  @override
  String get wordTermEmpty => 'Please enter the English word';

  @override
  String get wordMeaningEmpty => 'Please enter the Vietnamese meaning';

  @override
  String get deleteWordTitle => 'Delete word';

  @override
  String deleteWordMessage(String term) {
    return 'Are you sure you want to delete \"$term\"?';
  }

  @override
  String get wordAdded => 'Word added';

  @override
  String get wordUpdated => 'Word updated';

  @override
  String get wordDeleted => 'Word deleted';

  @override
  String get searchWords => 'Search words';

  @override
  String get filterAll => 'All';

  @override
  String get filterLearned => 'Learned';

  @override
  String get filterNotLearned => 'Not learned';

  @override
  String get filterFavorite => 'Favorite';

  @override
  String get sortTermAsc => 'A → Z';

  @override
  String get sortTermDesc => 'Z → A';

  @override
  String get sortLearnedFirst => 'Learned first';

  @override
  String get sortUnlearnedFirst => 'Not learned first';

  @override
  String get noSearchResults => 'No matching words found';

  @override
  String get studyTitle => 'Flashcard study';

  @override
  String get emptyDeckForStudy =>
      'This deck has no words. Please add words before studying.';

  @override
  String get tapToFlip => 'Tap the card to see its meaning';

  @override
  String get swipeHint => 'Swipe left or right to change cards';

  @override
  String get markLearned => 'Mark as learned';

  @override
  String get markNotLearned => 'Mark as not learned';

  @override
  String get learned => 'Learned';

  @override
  String get notLearned => 'Not learned';

  @override
  String cardPosition(int current, int total) {
    return '$current/$total';
  }

  @override
  String get studyFinished => 'You have finished this deck!';

  @override
  String get quizTitle => 'Quiz';

  @override
  String get notEnoughWords => 'A deck needs at least 4 words to create a quiz';

  @override
  String questionPosition(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get chooseQuizType => 'Choose quiz type';

  @override
  String get quizTypeMultipleChoice => 'Multiple choice';

  @override
  String get quizTypeMultipleChoiceDesc => 'Pick 1 of 4 answers';

  @override
  String get quizTypeTyping => 'Typing';

  @override
  String get quizTypeTypingDesc => 'Type the Vietnamese meaning';

  @override
  String get typingAnswerHint => 'Type the meaning...';

  @override
  String get checkAnswer => 'Check';

  @override
  String get answerCorrect => 'Correct!';

  @override
  String get answerIncorrect => 'Not quite';

  @override
  String get startQuiz => 'Start';

  @override
  String get questionPrompt => 'Choose the correct meaning of the word:';

  @override
  String get typingPrompt => 'Type the Vietnamese meaning of the word:';

  @override
  String get checkAnswerFirst => 'Please tap Check before continuing';

  @override
  String get nextQuestion => 'Next question';

  @override
  String get submitQuiz => 'Submit';

  @override
  String get selectAnswerFirst => 'Please select an answer';

  @override
  String comboLabel(int count) {
    return 'Combo x$count';
  }

  @override
  String get feedbackCorrect1 => 'Awesome!';

  @override
  String get feedbackCorrect2 => 'Correct!';

  @override
  String get feedbackCorrect3 => 'Well done!';

  @override
  String get feedbackIncorrect => 'Not quite, try again';

  @override
  String get quizResultTitle => 'Quiz result';

  @override
  String get yourScore => 'Your score';

  @override
  String correctCount(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get reviewAnswers => 'Review answers';

  @override
  String get yourAnswer => 'Your answer:';

  @override
  String get correctAnswer => 'Correct answer:';

  @override
  String get notAnswered => 'Not answered';

  @override
  String get retakeQuiz => 'Retake';

  @override
  String get backToDeck => 'Back to deck';

  @override
  String get historyTitle => 'Quiz history';

  @override
  String get emptyHistory => 'No quiz attempts yet';

  @override
  String get clearHistoryTitle => 'Clear history';

  @override
  String get clearHistoryMessage =>
      'Are you sure you want to clear all quiz history?';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get statisticsTitle => 'Learning progress';

  @override
  String get totalDecks => 'Total decks';

  @override
  String get totalWords => 'Total words';

  @override
  String get totalLearned => 'Words learned';

  @override
  String get overallProgress => 'Overall progress';

  @override
  String get progressByDeck => 'Progress by deck';

  @override
  String get emptyStatistics => 'No data to display yet';

  @override
  String get quizzesCompleted => 'Quizzes done';

  @override
  String get averageScore => 'Average score';

  @override
  String get profilesTitle => 'Profiles';

  @override
  String get addProfile => 'Add profile';

  @override
  String get profileName => 'Profile name';

  @override
  String get profileNameEmpty => 'Profile name cannot be empty';

  @override
  String get deleteProfileTitle => 'Delete profile';

  @override
  String deleteProfileMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? All decks and history for this profile will be lost.';
  }

  @override
  String get cannotDeleteLastProfile => 'Cannot delete the last profile';

  @override
  String get activeProfileLabel => 'Active';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get interfaceLanguage => 'Interface language';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get aboutTitle => 'Group information';

  @override
  String get projectName => 'English – Vietnamese Flashcard Vocabulary App';

  @override
  String get subjectName => 'Mobile Device Programming';

  @override
  String get universityName => 'Phenikaa University';

  @override
  String get groupLabel => 'Group 7 – Class N01';

  @override
  String get instructorLabel => 'Instructor';

  @override
  String get membersLabel => 'Group members';

  @override
  String get instructorName => 'Nguyen Xuan Que';
}
