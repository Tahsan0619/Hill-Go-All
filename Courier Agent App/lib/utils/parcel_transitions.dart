import '../models/parcel_model.dart';

/// Pure client-side validation for parcel status transitions, mirroring the
/// rules enforced by `App\Http\Controllers\Api\Courier\ParcelController`
/// (pickup requires `assigned`, transit/delivery require `picked_up` or
/// `in_transit`, and `delivered`/`failed` are terminal). Used to fail fast
/// with a friendly message before hitting the network, and is independently
/// unit-tested.
class ParcelTransitions {
  ParcelTransitions._();

  static const Map<ParcelStatus, Set<ParcelStatus>> _allowed = {
    ParcelStatus.assigned: {ParcelStatus.pickedUp, ParcelStatus.failed},
    ParcelStatus.pickedUp: {
      ParcelStatus.inTransit,
      ParcelStatus.delivered,
      ParcelStatus.failed,
    },
    ParcelStatus.inTransit: {ParcelStatus.delivered, ParcelStatus.failed},
    ParcelStatus.delivered: {},
    ParcelStatus.failed: {},
  };

  /// True when moving from [from] to [to] is a legal transition.
  static bool isValid(ParcelStatus from, ParcelStatus to) =>
      _allowed[from]?.contains(to) ?? false;

  /// True when [status] has no further legal transitions.
  static bool isTerminal(ParcelStatus status) => _allowed[status]?.isEmpty ?? true;

  static bool canConfirmPickup(ParcelStatus status) =>
      isValid(status, ParcelStatus.pickedUp);

  static bool canStartTransit(ParcelStatus status) =>
      isValid(status, ParcelStatus.inTransit);

  static bool canConfirmDelivery(ParcelStatus status) =>
      isValid(status, ParcelStatus.delivered);

  static bool canMarkFailed(ParcelStatus status) =>
      isValid(status, ParcelStatus.failed);
}
