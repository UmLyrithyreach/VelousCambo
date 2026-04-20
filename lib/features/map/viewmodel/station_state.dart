import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';

abstract class StationState {
  const StationState();
}

/// Provider created but init() not yet called.
class StationInitial extends StationState {
  const StationInitial();
}

/// Waiting for the first station list emission from Firestore.
class StationLoading extends StationState {
  const StationLoading();
}

/// Station data is available. All sub-state (selected station, bikes,
/// active rental, in-progress actions) lives here so data is never lost.
class StationLoaded extends StationState {
  final List<StationModel> stations;
  final StationModel? selectedStation;
  final List<BikeModel> selectedStationBikes;
  final RentalModel? activeRental;

  /// True while a start-rental or end-rental call is in flight.
  final bool isActionLoading;

  /// Non-null when the last start/end-rental action failed.
  final String? actionError;

  const StationLoaded({
    required this.stations,
    this.selectedStation,
    this.selectedStationBikes = const [],
    this.activeRental,
    this.isActionLoading = false,
    this.actionError,
  });

  bool get hasActiveRental => activeRental != null;

  StationLoaded copyWith({
    List<StationModel>? stations,
    Object? selectedStation = _sentinel,
    List<BikeModel>? selectedStationBikes,
    Object? activeRental = _sentinel,
    bool? isActionLoading,
    Object? actionError = _sentinel,
  }) {
    return StationLoaded(
      stations: stations ?? this.stations,
      selectedStation: selectedStation == _sentinel
          ? this.selectedStation
          : selectedStation as StationModel?,
      selectedStationBikes:
          selectedStationBikes ?? this.selectedStationBikes,
      activeRental: activeRental == _sentinel
          ? this.activeRental
          : activeRental as RentalModel?,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionError:
          actionError == _sentinel ? this.actionError : actionError as String?,
    );
  }
}

/// Stream subscription or one-off fetch failed.
class StationError extends StationState {
  final String message;
  const StationError(this.message);
}

// Sentinel to distinguish "pass null" from "do not override".
const Object _sentinel = Object();
