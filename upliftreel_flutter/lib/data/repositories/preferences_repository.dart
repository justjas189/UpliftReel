import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/movie.dart';
import '../../domain/models/user_preferences.dart';

/// Persistence + validation for [UserPreferences].
/// Clamps ported verbatim from legacy UserPreferenceManager.validatePreferences.
class PreferencesRepository {
  PreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'user_preferences';

  static final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  Future<UserPreferences> load() async {
    final stored = _prefs.getString(_key);
    if (stored == null) {
      final defaults = UserPreferences.defaults();
      await save(defaults);
      return defaults;
    }

    try {
      final parsed = UserPreferences.fromJson(
        jsonDecode(stored) as Map<String, dynamic>,
      );
      return validate(parsed);
    } on FormatException {
      return UserPreferences.defaults();
    } catch (_) {
      // Schema drift from an older install: fall back, same as legacy.
      return UserPreferences.defaults();
    }
  }

  Future<void> save(UserPreferences preferences) async {
    final validated = validate(preferences);
    await _prefs.setString(_key, jsonEncode(validated.toJson()));
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

  Future<void> reset() async {
    await _prefs.remove(_key);
  }
}
