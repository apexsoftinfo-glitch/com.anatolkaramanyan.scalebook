import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_data_source.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange.map((event) => event.session?.user);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<void> signInAnonymously() async {
    await _client.auth.signInAnonymously();
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> linkEmailToAnonymous(String email, String password) async {
    await _client.auth.updateUser(UserAttributes(email: email, password: password));
  }

  @override
  Future<void> deleteAccount() async {
    await _client.auth.signOut();
  }
}
