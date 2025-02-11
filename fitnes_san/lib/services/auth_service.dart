import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rejestracja użytkownika
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Błąd rejestracji: ${e.code} - ${e.message}');
      return null;
    }
  }

  // Logowanie użytkownika
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Błąd logowania: ${e.code} - ${e.message}');
      return null;
    }
  }

  // Wylogowanie użytkownika
  Future<void> signOut() async {
    await _auth.signOut();
  }
}



