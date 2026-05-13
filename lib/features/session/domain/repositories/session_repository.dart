import '../models/user_session.dart';
import '../../../profiles/models/profile_model.dart';

abstract class SessionRepository {
  /// Stream of current user session. Never emits errors.
  Stream<UserSession> get sessionStream;

  /// Current session (synchronous access)
  UserSession get current;

  /// Initialize repository and start listening to sources
  Future<void> initialize();

  /// Refresh all data sources
  Future<void> refresh();

  /// Sign in anonymously
  Future<void> signInAnonymously();

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password);

  /// Sign out
  Future<void> signOut();

  /// Reset password for email
  Future<void> resetPassword(String email);

  /// Verify reset code and set new password
  Future<void> verifyResetCode(String email, String code, String newPassword);

  /// Change password for current user
  Future<void> changePassword(String newPassword);

  /// Update profile
  Future<void> updateProfile(ProfileModel profile);

  /// Delete current user account and data
  Future<void> deleteAccount();

  /// Dispose all subscriptions
  void dispose();
}
