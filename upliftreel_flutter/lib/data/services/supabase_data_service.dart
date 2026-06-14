import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_config.dart';

/// Stateless wrapper over the Supabase PostgREST tables that back per-user
/// app state (see `supabase/migrations/20260614000000_user_data_isolation.sql`).
///
/// Raw maps in/out — domain mapping stays in the repositories. Every method is
/// scoped to the signed-in user via [_uid] and the table's RLS policy; there is
/// no code path that can address another user's rows.
///
/// Safe to construct unconditionally: when Supabase isn't configured (no keys,
/// e.g. unit tests and local-only builds) [isConfigured] is false and every
/// method short-circuits without touching `Supabase.instance`, which would
/// otherwise throw because it was never initialized.
class SupabaseDataService {
  /// Mirrors auth gating: data sync only happens when auth does.
  bool get isConfigured => ApiConfig.supabaseConfigured;

  SupabaseClient get _client => Supabase.instance.client;

  /// Current authenticated user id, or null when signed out / unconfigured.
  /// Callers also gate on this: no uid means nothing to sync.
  String? get _uid => isConfigured ? _client.auth.currentUser?.id : null;

  bool get _enabled => _uid != null;

  // -- Preferences (single row per user) -------------------------------------

  Future<Map<String, dynamic>?> fetchPreferences() async {
    if (!_enabled) return null;
    final row = await _client
        .from('preferences')
        .select('data')
        .eq('user_id', _uid!)
        .maybeSingle();
    final data = row?['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  Future<void> upsertPreferences(Map<String, dynamic> data) async {
    if (!_enabled) return;
    await _client.from('preferences').upsert({
      'user_id': _uid,
      'data': data,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // -- Mood entries (append-only log) ----------------------------------------

  Future<List<Map<String, dynamic>>> fetchMoodEntries() async {
    if (!_enabled) return const [];
    final rows = await _client
        .from('mood_entries')
        .select('client_id, mood, intensity, seriousness, created_at')
        .eq('user_id', _uid!)
        .order('created_at');
    return rows.cast<Map<String, dynamic>>();
  }

  /// Upserts on (user_id, client_id) so re-syncing the same local rows is
  /// idempotent. [rows] must each carry a stable `client_id`.
  Future<void> upsertMoodEntries(List<Map<String, dynamic>> rows) async {
    if (!_enabled || rows.isEmpty) return;
    await _client.from('mood_entries').upsert([
      for (final row in rows) {...row, 'user_id': _uid},
    ], onConflict: 'user_id,client_id');
  }

  // -- Watch history (recommendation / watched ledger) -----------------------

  Future<List<Map<String, dynamic>>> fetchWatchHistory() async {
    if (!_enabled) return const [];
    final rows = await _client
        .from('watch_history')
        .select(
          'movie_id, movie, is_recommendation, is_watched, '
          'match_score, recommended_at',
        )
        .eq('user_id', _uid!)
        .order('recommended_at');
    return rows.cast<Map<String, dynamic>>();
  }

  /// Upserts on (user_id, movie_id) — the table's primary key — so marking a
  /// movie watched updates the existing recommendation row in place.
  Future<void> upsertWatchHistory(List<Map<String, dynamic>> rows) async {
    if (!_enabled || rows.isEmpty) return;
    await _client.from('watch_history').upsert([
      for (final row in rows) {...row, 'user_id': _uid},
    ], onConflict: 'user_id,movie_id');
  }
}
