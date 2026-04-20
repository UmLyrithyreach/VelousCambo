import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';

/// Manages the search query for the station search screen.
/// Station data comes from [StationViewModel]; this ViewModel only
/// owns the query string and provides the filtered result.
class SearchViewModel extends ChangeNotifier {
  String _query = '';

  // ── State ─────────────────────────────────────────────────────────────────

  String get query => _query;

  // ── Actions ───────────────────────────────────────────────────────────────

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// Returns stations from [all] whose name or address contains [query].
  List<StationModel> filter(List<StationModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q))
        .toList();
  }
}
