import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/models/mood.dart';
import '../services/supabase_data_service.dart';

/// One logged mood selection. [clientId] is a stable app-side id used to
/// upsert idempotently against Supabase (re-syncing the same entry updates
/// rather than duplicates).
class MoodEntry {
  const MoodEntry({
    required this.input,
    required this.timestamp,
    required this.clientId,
  });

  final MoodInput input;
  final DateTime timestamp;
  final String clientId;

  Map<String, dynamic> toJson() => {
    'input': input.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'clientId': clientId,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.parse(json['timestamp'] as String);
    return MoodEntry(
      input: MoodInput.fromJson(json['input'] as Map<String, dynamic>),
      timestamp: timestamp,
      // Legacy entries predate clientId: derive a stable one from the
      // timestamp so they still round-trip and de-dupe on sync.
      clientId: json['clientId'] as String? ?? _deriveId(timestamp),
    );
  }

  /// Supabase row shape (see mood_entries table).
  Map<String, dynamic> toRow() => {
    'client_id': clientId,
    'mood': input.mood.name,
    'intensity': input.intensity,
    'seriousness': input.seriousness,
    'created_at': timestamp.toUtc().toIso8601String(),
  };

  static MoodEntry? fromRow(Map<String, dynamic> row) {
    final mood = Mood.values.where((m) => m.name == row['mood']).firstOrNull;
    if (mood == null) return null;
    return MoodEntry(
      input: MoodInput(
        mood: mood,
        intensity: (row['intensity'] as num).toInt(),
        seriousness: (row['seriousness'] as num).toInt(),
      ),
      timestamp: DateTime.parse(row['created_at'] as String).toLocal(),
      clientId: row['client_id'] as String,
    );
  }

  static String _deriveId(DateTime timestamp) =>
      'legacy-${timestamp.microsecondsSinceEpoch}';
}

/// Aggregates ported from legacy MoodDetectionService.getMoodInsights.
class MoodInsights {
  const MoodInsights({
    required this.mostCommonMood,
    required this.averageIntensity,
    required this.moodFrequency,
    required this.weeklyPattern,
  });

  final Mood mostCommonMood;
  final double averageIntensity;
  final Map<Mood, int> moodFrequency;

  /// Weekday name → most recently logged mood that day (legacy semantics:
  /// later entries overwrite earlier ones).
  final Map<String, Mood> weeklyPattern;
}

/// Mood log storage. Per-user namespaced (signed-in accounts never share a
/// log) with best-effort Supabase sync: writes upload when online, reads stay
/// local, and [pull] hydrates the local log from the cloud at app start.
class MoodRepository {
  MoodRepository(this._box, {String? userId, SupabaseDataService? dataService})
    : _userId = userId,
      _dataService = dataService;

  final Box<String> _box;
  final String? _userId;
  final SupabaseDataService? _dataService;

  static const String _baseKey = 'entries';

  /// Legacy cap: keep only the last 100 entries.
  static const int _maxEntries = 100;

  static const List<String> _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get _entriesKey =>
      _userId == null ? _baseKey : '${_baseKey}__$_userId';

  bool get _remoteEnabled =>
      _userId != null && (_dataService?.isConfigured ?? false);

  List<MoodEntry> entries() {
    final stored = _box.get(_entriesKey);
    if (stored == null) return [];
    return (jsonDecode(stored) as List)
        .whereType<Map<String, dynamic>>()
        .map(MoodEntry.fromJson)
        .toList();
  }

  Future<void> logMood(MoodInput input, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    final entry = MoodEntry(
      input: input,
      timestamp: timestamp,
      clientId: '${timestamp.microsecondsSinceEpoch}',
    );

    final all = entries()..add(entry);
    final capped = all.length > _maxEntries
        ? all.sublist(all.length - _maxEntries)
        : all;

    await _writeLocal(capped);

    if (_remoteEnabled) {
      try {
        await _dataService!.upsertMoodEntries([entry.toRow()]);
      } catch (_) {
        // Offline: local log stands; reconciled by the next [pull]/write.
      }
    }
  }

  /// Best-effort cloud → local hydration. Unions remote rows with the local
  /// log by [MoodEntry.clientId], keeps the most recent [_maxEntries], and
  /// silently no-ops offline or when sync is disabled.
  Future<void> pull() async {
    if (!_remoteEnabled) return;
    try {
      final rows = await _dataService!.fetchMoodEntries();
      final remote = rows
          .map(MoodEntry.fromRow)
          .whereType<MoodEntry>()
          .toList();
      if (remote.isEmpty) return;

      final byId = {for (final e in entries()) e.clientId: e};
      for (final e in remote) {
        byId[e.clientId] = e;
      }
      final merged = byId.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final capped = merged.length > _maxEntries
          ? merged.sublist(merged.length - _maxEntries)
          : merged;
      await _writeLocal(capped);
    } catch (_) {
      // Offline: keep local as-is.
    }
  }

  MoodInsights insights() {
    final all = entries();
    if (all.isEmpty) {
      return const MoodInsights(
        mostCommonMood: Mood.happy,
        averageIntensity: 5,
        moodFrequency: {},
        weeklyPattern: {},
      );
    }

    final frequency = <Mood, int>{};
    final weeklyPattern = <String, Mood>{};
    var totalIntensity = 0;

    for (final entry in all) {
      final mood = entry.input.mood;
      frequency[mood] = (frequency[mood] ?? 0) + 1;
      totalIntensity += entry.input.intensity;
      weeklyPattern[_weekdayNames[entry.timestamp.weekday - 1]] = mood;
    }

    final mostCommon = frequency.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;

    return MoodInsights(
      mostCommonMood: mostCommon,
      averageIntensity: totalIntensity / all.length,
      moodFrequency: frequency,
      weeklyPattern: weeklyPattern,
    );
  }

  Future<void> _writeLocal(List<MoodEntry> entries) async {
    await _box.put(
      _entriesKey,
      jsonEncode([for (final e in entries) e.toJson()]),
    );
  }
}
