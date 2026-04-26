import 'package:velouscambo_enhanced_new/models/rental_model.dart';

abstract class RideState {
  const RideState();
}

/// No booking in progress.
class RideInitial extends RideState {
  const RideInitial();
}

/// Action in progress (booking or ending rental).
class RideLoading extends RideState {
  const RideLoading();
}

/// An active ride is in progress.
class RideActive extends RideState {
  final RentalModel rental;
  final Duration elapsed;
  final int planLimitMinutes;
  final int remainingUnlockSeconds;
  final bool isUnlocking;

  const RideActive({
    required this.rental,
    required this.elapsed,
    required this.planLimitMinutes,
    required this.remainingUnlockSeconds,
    required this.isUnlocking,
  });
}

/// Booking failed.
class RideError extends RideState {
  final String message;
  const RideError(this.message);
}
