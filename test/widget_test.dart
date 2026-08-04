import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flashcard/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // DeckProvider.init() đọc SharedPreferences ngay khi ứng dụng dựng lên.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Ứng dụng khởi động và hiển thị được màn hình chính', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FlashcardApp());
    await tester.pumpAndSettle();

    expect(find.byType(FlashcardApp), findsOneWidget);
  });
}
