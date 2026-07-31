import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/main.dart';

void main() {
  testWidgets('Ứng dụng khởi động và hiển thị được màn hình chính',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FlashcardApp());
    await tester.pumpAndSettle();

    expect(find.byType(FlashcardApp), findsOneWidget);
  });
}
