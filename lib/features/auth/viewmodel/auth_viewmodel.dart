import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:velouscambo_enhanced_new/data/repositories/auth_repository.dart';
import 'package:velouscambo_enhanced_new/models/user_model.dart';
import 'package:velouscambo_enhanced_new/features/auth/viewmodel/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = const AuthInitial();
  User? _firebaseUser;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserModel?>? _userSub;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _authSub = _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  // ── State ─────────────────────────────────────────────────────────────────

  AuthState get state => _state;

  // ── Convenience getters (screens use these) ───────────────────────────────

  bool get isAuthenticated => _state is AuthAuthenticated;
  bool get isLoading => _state is AuthLoading;
  String? get error =>
      _state is AuthError ? (_state as AuthError).message : null;
  UserModel? get userModel =>
      _state is AuthAuthenticated ? (_state as AuthAuthenticated).user : null;

  /// Kept so screens can read `.firebaseUser?.uid` without changes.
  User? get firebaseUser => _firebaseUser;

  // ── Internal ──────────────────────────────────────────────────────────────

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    _userSub?.cancel();

    if (user == null) {
      _state = const AuthUnauthenticated();
      notifyListeners();
      return;
    }

    // Keep loading while Firestore profile hasn't arrived yet.
    if (_state is! AuthAuthenticated) {
      _state = const AuthLoading();
      notifyListeners();
    }

    _userSub = _repository.watchUser(user.uid).listen((model) {
      _state = model != null
          ? AuthAuthenticated(model)
          : const AuthUnauthenticated();
      notifyListeners();
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<bool> signIn(String email, String password) async {
    _state = const AuthLoading();
    notifyListeners();
    try {
      await _repository.signIn(email, password);
      // State transitions to AuthAuthenticated via _onAuthStateChanged.
      return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthError(_friendlyError(e.code));
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthError('Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _state = const AuthLoading();
    notifyListeners();
    try {
      final cred = await _repository.register(email, password);

      await _repository
          .createUserProfile(cred.user!.uid, name, email)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception(
            'Could not reach database. Check Firestore is enabled in Firebase Console.');
      });

      await _repository.seedDemoData().timeout(
            const Duration(seconds: 10),
            onTimeout: () {},
          );

      return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthError(_friendlyError(e.code));
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordReset(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (_firebaseUser == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    await _repository.updateProfile(_firebaseUser!.uid, data);
  }

  Future<void> updateUserPlan({required String plan, required DateTime expiry}) async {
    if (_firebaseUser == null) return;
    await _repository.updateProfile(_firebaseUser!.uid, {
      'plan': plan,
      'planExpiry': expiry.toIso8601String(),
    });
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'No account found with this email or password is incorrect.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled. '
            'Go to Firebase Console → Authentication → Sign-in method and enable it.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Error [$code]. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }
}
