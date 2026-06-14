import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/movie.dart';
import '../../domain/models/user_preferences.dart';
import '../services/supabase_data_service.dart';

/// Persistence + validation for [UserPreferences].
/// Clamps ported verbatim from legacy UserPreferenceManager.validatePreferences.
///
/// Storage is local-first and per-user: the SharedPreferences key is scoped by
/// [userId] so two accounts on one device never share a profile, and when
/// Supabase is reachable the row (RLS-bound to auth.uid()) is treated as the
/// cross-device source of truth. Every remote call is best-effort — offline or
/// unconfigured falls back cleanly to the namespaced local copy, never throws.
class PreferencesRepository {
  PreferencesRepository(
    this._prefs, {
    String? userId,
    SupabaseDataService? dataService,
  }) : _userId = userId,
       _dataService = dataService;

  final SharedPreferences _prefs;
  final String? _userId;
  final SupabaseDataService? _dataService;

  static const String _baseKey = 'user_preferences';

  static final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  /// Signed-out / local-only keeps the legacy un-suffixed key (back-compat);
  /// a signed-in user gets an isolated `user_preferences__<uid>` slot.
  String get _key => _userId == null ? _baseKey : '${_baseKey}__$_userId';

  bool get _remoteEnabled =>
      _userId != null && (_dataService?.isConfigured ?? false);

  Future<UserPreferences> load() async {
    // Remote wins when reachable (cross-device truth); fall back to the local
    // namespaced copy on any failure so offline use is seamless.
    if (_remoteEnabled) {
      try {
        final remote = await _dataService!.fetchPreferences();
        if (remote != null) {
          final prefs = _validateJson(remote);
          await _writeLocal(prefs);
          return prefs;
        }
      } catch (_) {
        return _loadLocal();
      }
      // Reachable but no row yet: seed the cloud from local, then return local.
      final local = await _loadLocal();
      await _pushRemote(local);
      return local;
    }
    return _loadLocal();
  }

  Future<void> save(UserPreferences preferences) async {
    final validated = validate(preferences);
    await _writeLocal(validated);
    await _pushRemote(validated);
  }

  Future<void> reset() async {
    await _prefs.remove(_key);
    // Reset must stick online too, or the next load would re-pull stale cloud
    // prefs. Overwrite the remote row with defaults rather than deleting it.
    if (_remoteEnabled) {
      try {
        await _dataService!.upsertPreferences(
          UserPreferences.defaults().toJson(),
        );
      } catch (_) {
        // Offline: local removal stands; cloud reconciles on next save.
      }
    }
  }

  UserPreferences validate(UserPreferences preferences) {
    var validated = preferences;

    if (validated.selectedGenres.isEmpty) {
      validated = validated.copyWith(
        selectedGenres: [Genre.comedy, Genre.drama],
      );
    }

    final minRating = validated.minRating.clamp(1.0, 10.0);
    final maxRating = validated.maxRating.clamp(minRating, 10.0);
    validated = validated.copyWith(minRating: minRating, maxRating: maxRating);

    final yearRange = validated.releaseYearRange;
    if (yearRange != null) {
      final currentYear = DateTime.now().year;
      final min = yearRange.min.clamp(1900, currentYear);
      final max = yearRange.max.clamp(min, currentYear);
      validated = validated.copyWith(
        releaseYearRange: ReleaseYearRange(min: min, max: max),
      );
    }

    final maxRuntime = validated.maxRuntime;
    if (maxRuntime != null) {
      validated = validated.copyWith(maxRuntime: maxRuntime.clamp(30, 300));
    }

    if (!_timePattern.hasMatch(validated.notificationTime)) {
      validated = validated.copyWith(notificationTime: '19:00');
    }

    if (!kPreferredLanguages.containsKey(validated.preferredLanguage)) {
      validated = validated.copyWith(preferredLanguage: 'en');
    }

    return validated;
  }

  // -- internals -------------------------------------------------------------

  Future<UserPreferences> _loadLocal() async {
    final stored = _prefs.getString(_key);
    if (stored == null) {
      final defaults = UserPreferences.defaults();
      await _writeLocal(defaults);
      return defaults;
    }

    try {
      return _validateJson(jsonDecode(stored) as Map<String, dynamic>);
    } on FormatException {
      return UserPreferences.defaults();
    } catch (_) {
      // Schema drift from an older install: fall back, same as legacy.
      return UserPreferences.defaults();
    }
  }

  UserPreferences _validateJson(Map<String, dynamic> json) =>
      validate(UserPreferences.fromJson(json));

  Future<void> _writeLocal(UserPreferences preferences) async {
    await _prefs.setString(_key, jsonEncode(validate(preferences).toJson()));
  }

  Future<void> _pushRemote(UserPreferences preferences) async {
    if (!_remoteEnabled) return;
    try {
      await _dataService!.upsertPreferences(preferences.toJson());
    } catch (_) {
      // Offline: local copy is authoritative until connectivity returns.
    }
  }
}
