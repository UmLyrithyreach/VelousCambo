// TODO: Vireak/Kimkheng — implement auth viewmodel (Story 2)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  User? get firebaseUser => FirebaseAuth.instance.currentUser;
}
