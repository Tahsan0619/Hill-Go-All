// Smoke test for the OTP entry widget used across the auth and delivery-
// confirmation flows. Replaces the original `1 + 1 == 2` placeholder — the
// real auth/OTP and status-transition logic is covered by
// `auth_otp_test.dart` and `parcel_transition_test.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_agent_app/widgets/otp_input.dart';

void main() {
  testWidgets('OtpInputRow reports the completed code once all digits are entered', (
    tester,
  ) async {
    String? completed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpInputRow(length: 4, onCompleted: (value) => completed = value),
        ),
      ),
    );

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));

    for (var i = 0; i < 4; i++) {
      await tester.enterText(fields.at(i), '$i');
      await tester.pump();
    }

    expect(completed, '0123');
  });
}
