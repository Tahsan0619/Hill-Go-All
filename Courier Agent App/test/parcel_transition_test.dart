import 'package:flutter_test/flutter_test.dart';
import 'package:courier_agent_app/models/parcel_model.dart';
import 'package:courier_agent_app/utils/parcel_transitions.dart';

void main() {
  group('ParcelTransitions.canConfirmPickup', () {
    test('true only from assigned', () {
      expect(ParcelTransitions.canConfirmPickup(ParcelStatus.assigned), isTrue);
      expect(ParcelTransitions.canConfirmPickup(ParcelStatus.pickedUp), isFalse);
      expect(ParcelTransitions.canConfirmPickup(ParcelStatus.inTransit), isFalse);
      expect(ParcelTransitions.canConfirmPickup(ParcelStatus.delivered), isFalse);
      expect(ParcelTransitions.canConfirmPickup(ParcelStatus.failed), isFalse);
    });
  });

  group('ParcelTransitions.canStartTransit', () {
    test('true only from pickedUp', () {
      expect(ParcelTransitions.canStartTransit(ParcelStatus.pickedUp), isTrue);
      expect(ParcelTransitions.canStartTransit(ParcelStatus.assigned), isFalse);
      expect(ParcelTransitions.canStartTransit(ParcelStatus.inTransit), isFalse);
    });
  });

  group('ParcelTransitions.canConfirmDelivery', () {
    test('true from pickedUp or inTransit', () {
      expect(ParcelTransitions.canConfirmDelivery(ParcelStatus.pickedUp), isTrue);
      expect(ParcelTransitions.canConfirmDelivery(ParcelStatus.inTransit), isTrue);
    });

    test('false from assigned, delivered, or failed', () {
      expect(ParcelTransitions.canConfirmDelivery(ParcelStatus.assigned), isFalse);
      expect(ParcelTransitions.canConfirmDelivery(ParcelStatus.delivered), isFalse);
      expect(ParcelTransitions.canConfirmDelivery(ParcelStatus.failed), isFalse);
    });
  });

  group('ParcelTransitions.canMarkFailed', () {
    test('true from assigned, pickedUp, or inTransit', () {
      expect(ParcelTransitions.canMarkFailed(ParcelStatus.assigned), isTrue);
      expect(ParcelTransitions.canMarkFailed(ParcelStatus.pickedUp), isTrue);
      expect(ParcelTransitions.canMarkFailed(ParcelStatus.inTransit), isTrue);
    });

    test('false once already finished', () {
      expect(ParcelTransitions.canMarkFailed(ParcelStatus.delivered), isFalse);
      expect(ParcelTransitions.canMarkFailed(ParcelStatus.failed), isFalse);
    });
  });

  group('ParcelTransitions.isTerminal', () {
    test('delivered and failed are terminal', () {
      expect(ParcelTransitions.isTerminal(ParcelStatus.delivered), isTrue);
      expect(ParcelTransitions.isTerminal(ParcelStatus.failed), isTrue);
    });

    test('assigned, pickedUp, inTransit are not terminal', () {
      expect(ParcelTransitions.isTerminal(ParcelStatus.assigned), isFalse);
      expect(ParcelTransitions.isTerminal(ParcelStatus.pickedUp), isFalse);
      expect(ParcelTransitions.isTerminal(ParcelStatus.inTransit), isFalse);
    });
  });
}
