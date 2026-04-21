import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/data/repositories/rental_repository.dart';
import 'package:velouscambo_enhanced_new/features/history/viewmodel/history_state.dart';

class HistoryViewModel extends ChangeNotifier {
  final RentalRepository _rentalRepo;

  HistoryState _state = const HistoryInitial();
  StreamSubscription<List<RentalModel>>? _historySub;

  HistoryViewModel({RentalRepository? rentalRepository})
      : _rentalRepo = rentalRepository ?? RentalRepository();

  // ── State ───

  HistoryState get state => _state;

  // ── Convenience getters (screens use these) ───

  List<RentalModel> get rentals =>
      _state is HistoryLoaded ? (_state as HistoryLoaded).rentals : const [];

  bool get isLoading => _state is HistoryLoading;

  String? get error =>
      _state is HistoryError ? (_state as HistoryError).message : null;

  // ── Load ───

  /// Starts listening to rental history for [userId].
  /// Safe to call multiple times — cancels any previous subscription first.
  void load(String userId) {
    _state = const HistoryLoading();
    notifyListeners();

    _historySub?.cancel();
    _historySub = _rentalRepo.watchRentalHistory(userId).listen(
      (list) {
        _state = HistoryLoaded(list);
        notifyListeners();
      },
      onError: (e) {
        _state = HistoryError('Failed to load ride history: $e');
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _historySub?.cancel();
    super.dispose();
  }
}
