import 'package:velouscambo_enhanced_new/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

/// Before the auth stream emits its first event.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Sign-in / register / any async auth operation in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Firebase user is signed in and the Firestore profile has loaded.
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}

/// No Firebase user (logged out or never signed in).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed (sign-in, register, etc.).
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
