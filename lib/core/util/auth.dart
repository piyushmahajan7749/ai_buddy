import 'package:ai_buddy/core/database/dbuser.dart';
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
      } else if (e.code == 'invalid-credential') {
        return 'Invalid user credentials.';
      }
    }
    return '';
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Auto-retrieve verification code
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        // Verification failed
      },
      codeSent: (verificationId, resendToken) async {
        // Save the verification ID for future use
        const String smsCode = 'xxxxxx'; // Code input by the user
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        // Sign the user in with the credential
        await auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return 'Password reset email has been sent!';
    } on Exception catch (e) {
      return 'Error: $e';
    }
  }

  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  String? getCurrentUserEmail() {
    return auth.currentUser?.email;
  }

  Future<String> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;

      await DbServiceUser(uid: user!.uid).createUserPref();
      return '';
    } on Exception catch (error) {
      return error.toString();
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
