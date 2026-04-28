import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}