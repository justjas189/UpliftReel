import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_config.dart';

/// OAuth callback registered in AndroidManifest.xml / Info.plist and in the
/// Supabase dashboard redirect allow-list. The trailing slash is required: it
/// must match the allow-list entry byte-for-byte, otherwise Supabase falls
/// back to the project Site URL (default http://localhost:3000) after login.
const String kAuthRedirectUrl = 'com.upliftreel.upliftreel://login-callback/';

/// Thin stateless wrapper over the GoTrue client: raw Supabase types in/out,
/// no domain mapping (that's AuthRepository's job).
class SupabaseAuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  bool get isConfigured => ApiConfig.supabaseConfigured;

  Session? get currentSession => _auth.currentSession;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) => _auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) => _auth.signUp(email: email, password: password);

  Future<bool> signInWithGoogle() => _auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: kIsWeb ? null : kAuthRedirectUrl,
    authScreenLaunchMode: LaunchMode.externalApplication,
  );

  Future<void> signOut() => _auth.signOut();
}
