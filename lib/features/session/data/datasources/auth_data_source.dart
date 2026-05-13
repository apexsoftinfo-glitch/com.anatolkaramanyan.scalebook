import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface for auth operations.
abstract class AuthDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> signInAnonymously();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> verifyOTP(String email, String token, OtpType type);
  Future<void> linkEmailToAnonymous(String email, String password);
  Future<void> deleteAccount();
}
