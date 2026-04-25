import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/data/repositories/rental_repository.dart';
import 'package:velouscambo_enhanced_new/features/ride/state/ride_state.dart';

class RideViewModel extends ChangeNotifier {
  final RentalRepository _rentalRepo;

  RideState _state = const RideInitial();
  StreamSubscription<RentalModel?>? _rentalSub;
  String? _currentPlan;

  RideViewModel({RentalRepository? rentalRepository})
      : _rentalRepo = rentalRepository ?? RentalRepository();

// ── State ────

  RideState get state => _state;

// ── Convenience getters ───

  /// Current active rental, if any.
  RentalModel? get activeRental =>
      _state is RideActive ? (_state as RideActive).rental : null;

  /// Whether a background operation is in progress.
  bool get isLoading => _state is RideLoading;

  /// Error message if the last operation failed.
  String? get error =>
      _state is RideError ? (_state as RideError).message : null;

  /// Alias for activeRental, used by some screens for compatibility.
  RentalModel? get bookedRental => activeRental;

// ── Actions ───

  int _calculateLimit(String? plan) {
    switch (plan?.toLowerCase()) {
      case 'daily': return 30;
      case 'monthly': return 45;
      case 'annual': return 60;
      default: return 30;
    }
  }

  /// Initializes the subscription to watch for an active rental.
  void init(String userId, [String? plan]) {
    _currentPlan = plan;
    _rentalSub?.cancel();
    _rentalSub = _rentalRepo.watchActiveRental(userId).listen((rental) {
      if (rental != null) {
        _state = RideActive(
          rental: rental,
          planLimitMinutes: _calculateLimit(_currentPlan),
        );
      } else {
        if (_state is! RideLoading) {
          _state = const RideInitial();
        }
      }
      notifyListeners();
    });
  }

  /// Starts a new rental.
  Future<bool> book({
    required String userId,
    required BikeModel bike,
    required StationModel station,
  }) async {
    _state = const RideLoading();
    notifyListeners();
    try {
      final rental = await _rentalRepo.startRental(
        userId: userId,
        bike: bike,
        station: station,
      );
      _state = RideActive(
        rental: rental,
        planLimitMinutes: _calculateLimit(_currentPlan),
      );
      notifyListeners();
      return true;
    } catch (_) {
      _state = const RideError('Failed to start rental. Please try again.');
      notifyListeners();
      return false;
    }
  }

  /// Ends the currently active rental.
  Future<bool> endRental() async {
    final currentState = _state;
    if (currentState is! RideActive) return false;
    
    final rental = currentState.rental;
    _state = const RideLoading();
    notifyListeners();

    try {
      await _rentalRepo.endRental(
        rentalId: rental.id,
        bikeId: rental.bikeId,
        stationId: rental.stationId,
        startTime: rental.startTime,
      );
      _state = const RideInitial();
      notifyListeners();
      return true;
    } catch (_) {
      _state = const RideError('Failed to end rental. Please try again.');
      notifyListeners();
      return false;
    }
  }

  /// Manually set an active rental (e.g. from local scan before Firestore updates).
  void setActiveRental(RentalModel rental) {
    _state = RideActive(
      rental: rental,
      planLimitMinutes: _calculateLimit(_currentPlan),
    );
    notifyListeners();
  }

  /// Clears the active ride state.
  void clearActiveRental() {
    _state = const RideInitial();
    notifyListeners();
  }

  /// Resets state to initial.
  void reset() {
    _state = const RideInitial();
    notifyListeners();
  }

  @override
  void dispose() {
    _rentalSub?.cancel();
    super.dispose();
  }
}
