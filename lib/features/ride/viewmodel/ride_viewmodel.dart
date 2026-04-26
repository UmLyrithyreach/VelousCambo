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
  RideState get state => _state;
  bool get isLoading => _state is RideLoading;

  StreamSubscription<RentalModel?>? _rentalSub;
  Timer? _ticker;

  RentalModel? _currentRental;
  String? _currentPlan;

  RideViewModel({RentalRepository? rentalRepository})
      : _rentalRepo = rentalRepository ?? RentalRepository();

  // ── Helpers ─────────────────────────────────────

  int _calculateLimit(String? plan) {
    switch (plan?.toLowerCase()) {
      case 'daily':
        return 30;
      case 'monthly':
        return 45;
      case 'annual':
        return 60;
      default:
        return 30;
    }
  }

  void _emitActiveState() {
    if (_currentRental == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentRental!.startTime);

    final remainingUnlockSeconds =
        (30 - elapsed.inSeconds).clamp(0, 30).toInt();

    final isUnlocking = remainingUnlockSeconds > 0;

    _state = RideActive(
      rental: _currentRental!,
      elapsed: elapsed,
      planLimitMinutes: _calculateLimit(_currentPlan),
      remainingUnlockSeconds: remainingUnlockSeconds,
      isUnlocking: isUnlocking,
    );

    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _emitActiveState();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  // ── Init ───────────────────────────────────────

  void init(String userId, [String? plan]) {
    _currentPlan = plan;

    _rentalSub?.cancel();
    _rentalSub = _rentalRepo.watchActiveRental(userId).listen((rental) {
      _currentRental = rental;

      if (rental != null) {
        _startTicker();
        _emitActiveState(); // immediate update
      } else {
        _stopTicker();
        _state = const RideInitial();
        notifyListeners();
      }
    });
  }

  // ── Actions ────────────────────────────────────

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

      _currentRental = rental;
      _startTicker();
      _emitActiveState();

      return true;
    } catch (_) {
      _state = const RideError('Failed to start rental.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> endRental() async {
    if (_currentRental == null) return false;

    _state = const RideLoading();
    notifyListeners();

    try {
      await _rentalRepo.endRental(
        rentalId: _currentRental!.id,
        bikeId: _currentRental!.bikeId,
        stationId: _currentRental!.stationId,
        startTime: _currentRental!.startTime,
      );

      _currentRental = null;
      _stopTicker();

      _state = const RideInitial();
      notifyListeners();

      return true;
    } catch (_) {
      _state = const RideError('Failed to end rental.');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _rentalSub?.cancel();
    _stopTicker();
    super.dispose();
  }
}
