import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/data/repositories/rental_repository.dart';
import 'package:velouscambo_enhanced_new/features/ride/viewmodel/ride_state.dart';

class RideViewModel extends ChangeNotifier {
  final RentalRepository _rentalRepo;

  RideState _state = const RideInitial();

  RideViewModel({RentalRepository? rentalRepository})
      : _rentalRepo = rentalRepository ?? RentalRepository();

  // ── State ─────────────────────────────────────────────────────────────────

  RideState get state => _state;

  // ── Convenience getters (screens use these) ───────────────────────────────

  bool get isLoading => _state is RideConfirming;

  String? get error =>
      _state is RideError ? (_state as RideError).message : null;

  RentalModel? get bookedRental =>
      _state is RideBooked ? (_state as RideBooked).rental : null;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Confirms the booking for [bike] at [station] for [userId].
  /// Returns `true` on success. The new rental is also picked up by
  /// [StationViewModel] via its Firestore subscription, so [hasActiveRental]
  /// updates automatically across the app.
  Future<bool> book({
    required String userId,
    required BikeModel bike,
    required StationModel station,
  }) async {
    _state = const RideConfirming();
    notifyListeners();

    try {
      final rental = await _rentalRepo.startRental(
        userId: userId,
        bike: bike,
        station: station,
      );
      _state = RideBooked(rental);
      notifyListeners();
      return true;
    } catch (_) {
      _state = const RideError('Failed to start rental. Please try again.');
      notifyListeners();
      return false;
    }
  }

  /// Resets back to [RideInitial] so the booking screen can be reused.
  void reset() {
    _state = const RideInitial();
    notifyListeners();
  }
}
