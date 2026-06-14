/// User-readable auth error. The data layer maps provider exceptions
/// (supabase AuthException, missing config) into this so the UI never
/// needs to know Supabase types.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
