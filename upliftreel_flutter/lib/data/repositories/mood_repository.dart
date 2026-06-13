import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/models/mood.dart';

/// One logged mood selection.
class MoodEntry {
  const MoodEntry({required this.input, required this.timestamp});

  final MoodInput input;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'input': input.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        input: MoodInput.fromJson(json['input'] as Map<String, dynamic>),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
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

/// Mood log storage. Legacy kept this inside static MoodDetectionService
/// methods with inline AsyncStorage requires — the Phase 0 coupling flag.
class MoodRepository {
  MoodRepository(this._box);

  final Box<String> _box;

  static const String _entriesKey = 'entries';

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

  List<MoodEntry> entries() {
    final stored = _box.get(_entriesKey);
    if (stored == null) return [];
    return (jsonDecode(stored) as List)
        .whereType<Map<String, dynamic>>()
        .map(MoodEntry.fromJson)
        .toList();
  }

  Future<void> logMood(MoodInput input, {DateTime? now}) async {
    final all = entries()
      ..add(MoodEntry(input: input, timestamp: now ?? DateTime.now()));

    final capped = all.length > _maxEntries
        ? all.sublist(all.length - _maxEntries)
        : all;

    await _box.put(
      _entriesKey,
      jsonEncode([for (final e in capped) e.toJson()]),
    );
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
}
