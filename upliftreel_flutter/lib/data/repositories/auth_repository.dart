import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/models/auth_failure.dart';
import '../../domain/models/auth_user.dart';
import '../services/supabase_auth_service.dart';

/// Outcome of an email/password sign-up: Supabase returns no session when
/// email confirmation is enabled, so the UI must tell those cases apart.
enum SignUpResult { signedIn, confirmationEmailSent }

/// Maps raw Supabase auth into domain [AuthUser]s and provider exceptions
/// into user-readable [AuthFailure]s.
class AuthRepository {
  AuthRepository({required SupabaseAuthService service}) : _service = service;

  final SupabaseAuthService _service;

  bool get isConfigured => _service.isConfigured;

  AuthUser? get currentUser =>
      isConfigured ? _toDomain(_service.currentUser) : null;

  /// Emits on every session change (sign-in, sign-out, token refresh,
  /// OAuth deep-link completion).
  Stream<AuthUser?> authStateChanges() =>
      _service.onAuthStateChange.map((state) => _toDomain(state.session?.user));

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(
    () => _service.signInWithPassword(email: email, password: password),
  );

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _service.signUp(email: email, password: password);
    return response.session == null
        ? SignUpResult.confirmationEmailSent
        : SignUpResult.signedIn;
  });

  /// Launches the browser OAuth flow; the session lands asynchronously via
  /// [authStateChanges] once the deep link returns.
  Future<void> signInWithGoogle() => _guard(() => _service.signInWithGoogle());

  Future<void> signOut() => _guard(() => _service.signOut());

  Future<T> _guard<T>(Future<T> Function() action) async {
    if (!isConfigured) {
      throw const AuthFailure(
        'Sign-in unavailable: add SUPABASE_URL and SUPABASE_ANON_KEY '
        'to dart-defines.json and rebuild.',
      );
    }
    try {
      return await action();
    } on supabase.AuthException catch (exception) {
      throw AuthFailure(exception.message);
    }
  }

  AuthUser? _toDomain(supabase.User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      // Google populates full_name/name + avatar_url/picture; email sign-ups
      // have none of these and fall back to null.
      displayName: (metadata['full_name'] ?? metadata['name']) as String?,
      avatarUrl: (metadata['avatar_url'] ?? metadata['picture']) as String?,
    );
  }
}
