/// API keys injected via --dart-define-from-file=config/api-keys.json.
///
/// Copy config/api-keys.template.json → config/api-keys.json and fill in values.
/// VS Code launch.json already passes --dart-define-from-file.
/// For CLI: flutter run --dart-define-from-file=config/api-keys.json
class ApiKeys {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const revenueCatAppleApiKey =
      String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  static const revenueCatGoogleApiKey =
      String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');

  static const bool isSupabaseConfigured = supabaseUrl != '' && supabaseAnonKey != '';
}
