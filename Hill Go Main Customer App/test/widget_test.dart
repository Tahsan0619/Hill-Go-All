import 'package:flutter_test/flutter_test.dart';

import 'package:hillgo/main.dart';

void main() {
  testWidgets('App launches on splash', (WidgetTester tester) async {
    await tester.pumpWidget(const HillGoApp());
    expect(find.text('HillGo'), findsWidgets);
    expect(find.text('Your Journey, Our Priority'), findsOneWidget);

    // Splash restores session + waits ~2.2s before navigating away.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
  });
}
