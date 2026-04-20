import 'package:firebase_auth/firebase_auth.dart';
import 'package:velouscambo_enhanced_new/models/user_model.dart';
import 'package:velouscambo_enhanced_new/data/services/auth_service.dart';
import 'package:velouscambo_enhanced_new/data/services/firestore_service.dart';

class AuthRepository {
  final AuthService _auth;
  final FirestoreService _firestore;

  AuthRepository()
      : _auth = AuthService(),
        _firestore = FirestoreService();

  // ── Auth stream ────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges;

  User? get currentUser => _auth.currentUser;

  // ── User profile ──────────────────────────────────────────────────────────

  Stream<UserModel?> watchUser(String uid) => _firestore.getUser(uid);

  Future<void> createUserProfile(String uid, String name, String email) =>
      _firestore.createUser(uid, name, email);

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _firestore.updateUser(uid, data);

  // ── Sign-in / register ────────────────────────────────────────────────────

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signIn(email, password);

  Future<UserCredential> register(String email, String password) =>
      _auth.register(email, password);

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  // ── Seed ──────────────────────────────────────────────────────────────────

  Future<void> seedDemoData() => _firestore.seedDemoData();
}
