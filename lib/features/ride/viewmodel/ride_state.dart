import 'package:velouscambo_enhanced_new/models/rental_model.dart';

abstract class RideState {
  const RideState();
}

/// No booking in progress.
class RideInitial extends RideState {
  const RideInitial();
}

/// Booking request is being sent to Firestore.
class RideConfirming extends RideState {
  const RideConfirming();
}

/// Booking succeeded — rental has started.
class RideBooked extends RideState {
  final RentalModel rental;
  const RideBooked(this.rental);
}

/// Booking failed.
class RideError extends RideState {
  final String message;
  const RideError(this.message);
}
