import 'package:flutter_test/flutter_test.dart';
import 'package:upliftreel/domain/models/mood.dart';
import 'package:upliftreel/domain/mood_suggestions.dart';

void main() {
  group('moodSuggestionsFor (legacy time-bucket parity)', () {
    test('morning 6–12', () {
      final suggestions = moodSuggestionsFor(DateTime(2026, 6, 12, 8));
      expect(suggestions.map((s) => s.mood),
          [Mood.excited, Mood.happy, Mood.curious]);
      expect(suggestions.first.label, 'Energetic');
    });

    test('afternoon 12–18', () {
      final suggestions = moodSuggestionsFor(DateTime(2026, 6, 12, 14));
      expect(suggestions.map((s) => s.mood),
          [Mood.adventurous, Mood.romantic, Mood.curious]);
      expect(suggestions.last.label, 'Thoughtful');
    });

    test('evening 18–24', () {
      final suggestions = moodSuggestionsFor(DateTime(2026, 6, 12, 21));
      expect(suggestions.map((s) => s.mood),
          [Mood.relaxed, Mood.suspense, Mood.introspective]);
      expect(suggestions.first.label, 'Chill');
    });

    test('night 0–6', () {
      final suggestions = moodSuggestionsFor(DateTime(2026, 6, 12, 2));
      expect(suggestions.map((s) => s.mood),
          [Mood.relaxed, Mood.introspective, Mood.romantic]);
      expect(suggestions.first.label, 'Peaceful');
    });
  });
}
