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
  final int planLimitMinutes; // Data prepared for the UI
  
  const RideActive({
    required this.rental,
    required this.planLimitMinutes,
  });
}

/// Booking failed.
class RideError extends RideState {
  final String message;
  const RideError(this.message);
}
