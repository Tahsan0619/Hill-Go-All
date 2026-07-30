import 'package:flutter_test/flutter_test.dart';

import 'package:hillgo/main.dart';

void main() {
  testWidgets('App launches on splash', (WidgetTester tester) async {
    await tester.pumpWidget(const HillGoApp());
    expect(find.text('HillGo'), findsWidgets);
    expect(find.text('Your Journey, Our Priority'), findsOneWidget);
  });
}
