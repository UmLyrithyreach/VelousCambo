import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/data/repositories/auth_repository.dart';
import 'package:velouscambo_enhanced_new/features/profile/viewmodel/profile_state.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  ProfileState _state = const ProfileInitial();

  ProfileViewModel({AuthRepository? authRepository})
      : _repository = authRepository ?? AuthRepository();

  // ── State ─────────────────────────────────────────────────────────────────

  ProfileState get state => _state;

  // ── Convenience getters (screens use these) ───────────────────────────────

  bool get isLoading => _state is ProfileSaving;

  String? get error =>
      _state is ProfileError ? (_state as ProfileError).message : null;

  bool get saved => _state is ProfileSaved;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Saves profile changes for [uid]. Pass only the fields that changed.
  Future<void> updateProfile(
    String uid, {
    String? name,
    String? photoUrl,
  }) async {
    _state = const ProfileSaving();
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      await _repository.updateProfile(uid, data);
      _state = const ProfileSaved();
      notifyListeners();
    } catch (e) {
      _state = ProfileError(e.toString());
      notifyListeners();
    }
  }

  /// Resets to [ProfileInitial] (e.g. after navigating away from edit screen).
  void reset() {
    _state = const ProfileInitial();
    notifyListeners();
  }
}
