import 'package:ai_buddy/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<String> emailSignIn(String email, String pwd) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: pwd);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return '';
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return 'Password reset email has been sent!';
    } on Exception catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> deleteUser() async {
    try {
      await auth.currentUser?.delete();
    } catch (e) {
      // Handle or rethrow the error as needed
    }
  }
}
