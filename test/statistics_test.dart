import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flashcard/l10n/app_localizations.dart';
import 'package:flashcard/models/quiz_result.dart';
import 'package:flashcard/models/quiz_type.dart';
import 'package:flashcard/models/word.dart';
import 'package:flashcard/providers/deck_provider.dart';
import 'package:flashcard/providers/quiz_provider.dart';
import 'package:flashcard/screens/statistics_screen.dart';

/// Dựng dữ liệu cố định: bộ A có 5 từ (4 đã thuộc), bộ B có 3 từ (0 đã thuộc).
DeckProvider _buildDeckProvider() {
  final provider = DeckProvider();

  provider.addDeck('Bộ A');
  provider.addDeck('Bộ B');
  final decks = provider.getDecks();

  for (var i = 0; i < 5; i++) {
    provider.addWord(
      decks[0].id,
      Word(id: '', term: 'a$i', meaning: 'nghĩa $i', isLearned: i < 4),
    );
  }
  for (var i = 0; i < 3; i++) {
    provider.addWord(
      decks[1].id,
      Word(id: '', term: 'b$i', meaning: 'nghĩa $i'),
    );
  }

  return provider;
}

Future<QuizProvider> _buildQuizProvider() async {
  final provider = QuizProvider();

  // 4/5 = 80%, 2/4 = 50%, 1/5 = 20% -> trung bình 50%.
  await provider.saveResult(
    'Bộ A',
    QuizResult(
      totalQuestions: 5,
      correctAnswers: 4,
      questions: [],
      userAnswers: {},
    ),
    QuizType.multipleChoice,
  );
  await provider.saveResult(
    'Bộ A',
    QuizResult(
      totalQuestions: 4,
      correctAnswers: 2,
      questions: [],
      userAnswers: {},
    ),
    QuizType.typing,
  );
  await provider.saveResult(
    'Bộ B',
    QuizResult(
      totalQuestions: 5,
      correctAnswers: 1,
      questions: [],
      userAnswers: {},
    ),
    QuizType.multipleChoice,
  );

  return provider;
}

Widget _wrap(DeckProvider deckProvider, QuizProvider quizProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<DeckProvider>.value(value: deckProvider),
      ChangeNotifierProvider<QuizProvider>.value(value: quizProvider),
    ],
    child: const MaterialApp(
      locale: Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StatisticsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Số liệu tổng quan tính đúng', (tester) async {
    final deckProvider = _buildDeckProvider();
    final quizProvider = await _buildQuizProvider();

    await tester.pumpWidget(_wrap(deckProvider, quizProvider));
    await tester.pumpAndSettle();

    // 2 bộ từ, 8 từ (5 + 3), 4 từ đã thuộc, 3 lượt làm bài.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    // '4' xuất hiện ở ô "Số từ đã thuộc" và ở cả hai dòng chú thích
    // (đã thuộc 4 / chưa thuộc 8 - 4 = 4).
    expect(find.text('4'), findsNWidgets(3));
  });

  testWidgets('Tiến độ từng bộ và điểm trung bình tính đúng', (tester) async {
    final deckProvider = _buildDeckProvider();
    final quizProvider = await _buildQuizProvider();

    await tester.pumpWidget(_wrap(deckProvider, quizProvider));
    await tester.pumpAndSettle();

    // Bộ A: 4/5 = 80%, bộ B: 0/3 = 0%.
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Đã thuộc 4/5'), findsOneWidget);
    expect(find.text('Đã thuộc 0/3'), findsOneWidget);

    // Trung bình (0.8 + 0.5 + 0.2) / 3 = 50%.
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('Không có bộ từ nào thì hiện trạng thái trống', (tester) async {
    final quizProvider = await _buildQuizProvider();

    await tester.pumpWidget(_wrap(DeckProvider(), quizProvider));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có dữ liệu để thống kê'), findsOneWidget);
    expect(find.text('50%'), findsNothing);
  });
}
