import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/data/repositories/rental_repository.dart';
import 'package:velouscambo_enhanced_new/data/repositories/station_repository.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_state.dart';

class StationViewModel extends ChangeNotifier {
  final StationRepository _stationRepo;
  final RentalRepository _rentalRepo;

  StationState _state = const StationInitial();

  StreamSubscription<List<StationModel>>? _stationsSub;
  StreamSubscription<List<BikeModel>>? _bikesSub;
  StreamSubscription<RentalModel?>? _rentalSub;

  StationViewModel({
    StationRepository? stationRepository,
    RentalRepository? rentalRepository,
  })  : _stationRepo = stationRepository ?? StationRepository(),
        _rentalRepo = rentalRepository ?? RentalRepository();

  // ── State ─────────────────────────────────────────────────────────────────

  StationState get state => _state;

  // ── Convenience getters (screens use these) ───────────────────────────────

  List<StationModel> get stations =>
      _state is StationLoaded ? (_state as StationLoaded).stations : const [];

  StationModel? get selectedStation =>
      _state is StationLoaded ? (_state as StationLoaded).selectedStation : null;

  List<BikeModel> get selectedStationBikes => _state is StationLoaded
      ? (_state as StationLoaded).selectedStationBikes
      : const [];

  RentalModel? get activeRental =>
      _state is StationLoaded ? (_state as StationLoaded).activeRental : null;

  bool get hasActiveRental =>
      _state is StationLoaded && (_state as StationLoaded).hasActiveRental;

  /// True during initial load OR while a start/end-rental call is in flight.
  bool get isLoading =>
      _state is StationLoading ||
      (_state is StationLoaded && (_state as StationLoaded).isActionLoading);

  String? get error => _state is StationLoaded
      ? (_state as StationLoaded).actionError
      : null;

  // ── Init ──────────────────────────────────────────────────────────────────

  void init(String userId) {
    _state = const StationLoading();
    notifyListeners();

    _stationsSub?.cancel();
    _stationsSub = _stationRepo.watchStations().listen((list) {
      final current =
          _state is StationLoaded ? _state as StationLoaded : null;
      _state = (current ?? const StationLoaded(stations: [])).copyWith(
        stations: list,
      );
      notifyListeners();
    }, onError: (_) {
      _state = const StationError('Failed to load stations.');
      notifyListeners();
    });

    _rentalSub?.cancel();
    _rentalSub = _rentalRepo.watchActiveRental(userId).listen((rental) {
      if (_state is StationLoaded) {
        _state = (_state as StationLoaded).copyWith(activeRental: rental);
        notifyListeners();
      }
    });
  }

  // ── Station selection ─────────────────────────────────────────────────────

  void selectStation(StationModel station) {
    if (_state is! StationLoaded) return;
    _state = (_state as StationLoaded).copyWith(
      selectedStation: station,
      selectedStationBikes: [],
    );
    notifyListeners();

    _bikesSub?.cancel();
    _bikesSub =
        _stationRepo.watchBikesForStation(station.id).listen((bikes) {
      if (_state is StationLoaded) {
        _state =
            (_state as StationLoaded).copyWith(selectedStationBikes: bikes);
        notifyListeners();
      }
    });
  }

  void clearSelectedStation() {
    if (_state is! StationLoaded) return;
    _bikesSub?.cancel();
    _state = (_state as StationLoaded).copyWith(
      selectedStation: null,
      selectedStationBikes: [],
    );
    notifyListeners();
  }

  // ── Rental actions ────────────────────────────────────────────────────────

  Future<RentalModel?> startRental({
    required String userId,
    required BikeModel bike,
    required StationModel station,
  }) async {
    if (_state is! StationLoaded) return null;
    _state = (_state as StationLoaded).copyWith(
      isActionLoading: true,
      actionError: null,
    );
    notifyListeners();

    try {
      final rental = await _rentalRepo.startRental(
        userId: userId,
        bike: bike,
        station: station,
      );
      _state = (_state as StationLoaded).copyWith(
        isActionLoading: false,
        activeRental: rental,
      );
      notifyListeners();
      return rental;
    } catch (_) {
      _state = (_state as StationLoaded).copyWith(
        isActionLoading: false,
        actionError: 'Failed to start rental. Please try again.',
      );
      notifyListeners();
      return null;
    }
  }

  Future<bool> endRental() async {
    if (_state is! StationLoaded) return false;
    final loaded = _state as StationLoaded;
    if (loaded.activeRental == null) return false;

    _state = loaded.copyWith(isActionLoading: true, actionError: null);
    notifyListeners();

    try {
      await _rentalRepo.endRental(
        rentalId: loaded.activeRental!.id,
        bikeId: loaded.activeRental!.bikeId,
        stationId: loaded.activeRental!.stationId,
        startTime: loaded.activeRental!.startTime,
      );
      _state = (_state as StationLoaded).copyWith(
        isActionLoading: false,
        activeRental: null,
      );
      notifyListeners();
      return true;
    } catch (_) {
      _state = (_state as StationLoaded).copyWith(
        isActionLoading: false,
        actionError: 'Failed to end rental. Please try again.',
      );
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _stationsSub?.cancel();
    _bikesSub?.cancel();
    _rentalSub?.cancel();
    super.dispose();
  }
}
