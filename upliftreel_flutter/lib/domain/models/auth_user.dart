/// Authenticated account as the app sees it; data layer maps the raw
/// Supabase user (metadata keys differ per provider) into this.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName &&
      other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, email, displayName, avatarUrl);
}
