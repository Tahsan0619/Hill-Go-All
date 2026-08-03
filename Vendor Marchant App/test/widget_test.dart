import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_marchant_app/widgets/common_widgets.dart';

/// Smoke test replacing the old `expect(true, isTrue)` placeholder.
/// Provider/repository logic is covered separately in
/// orders_provider_test.dart and store_provider_test.dart; this exercises a
/// real widget so a broken shared component fails CI.
void main() {
  testWidgets('EmptyView renders its message and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyView(
            message: 'No delivered orders found.',
            icon: Icons.inbox_outlined,
          ),
        ),
      ),
    );

    expect(find.text('No delivered orders found.'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('ErrorView shows a retry button that invokes the callback',
      (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Something went wrong',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried, isTrue);
  });
}
