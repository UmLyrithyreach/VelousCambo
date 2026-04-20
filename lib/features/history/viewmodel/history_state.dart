import 'package:velouscambo_enhanced_new/models/rental_model.dart';

abstract class HistoryState {
  const HistoryState();
}

/// Before the user's rental history has been loaded.
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Fetching rental history from Firestore.
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Rental history loaded successfully.
class HistoryLoaded extends HistoryState {
  final List<RentalModel> rentals;
  const HistoryLoaded(this.rentals);
}

/// Failed to load rental history.
class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
}
