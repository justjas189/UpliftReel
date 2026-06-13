import 'models/mood.dart';

/// One time-of-day mood suggestion.
class MoodSuggestion {
  const MoodSuggestion({
    required this.mood,
    required this.label,
    required this.description,
  });

  final Mood mood;
  final String label;
  final String description;
}

/// Ported verbatim from legacy MoodDetectionService.getMoodSuggestions,
/// with the clock injected. Legacy buckets: morning 6–12, afternoon 12–18,
/// evening 18–24, night 0–6.
List<MoodSuggestion> moodSuggestionsFor(DateTime now) {
  final hour = now.hour;

  if (hour >= 6 && hour < 12) {
    return const [
      MoodSuggestion(
        mood: Mood.excited,
        label: 'Energetic',
        description: 'Ready for adventure!',
      ),
      MoodSuggestion(
        mood: Mood.happy,
        label: 'Upbeat',
        description: 'Feeling positive and light',
      ),
      MoodSuggestion(
        mood: Mood.curious,
        label: 'Curious',
        description: 'Want to learn something new',
      ),
    ];
  }

  if (hour >= 12 && hour < 18) {
    return const [
      MoodSuggestion(
        mood: Mood.adventurous,
        label: 'Adventurous',
        description: 'Ready for excitement',
      ),
      MoodSuggestion(
        mood: Mood.romantic,
        label: 'Romantic',
        description: 'In the mood for love',
      ),
      MoodSuggestion(
        mood: Mood.curious,
        label: 'Thoughtful',
        description: 'Want something meaningful',
      ),
    ];
  }

  if (hour >= 18) {
    return const [
      MoodSuggestion(
        mood: Mood.relaxed,
        label: 'Chill',
        description: 'Want to unwind',
      ),
      MoodSuggestion(
        mood: Mood.suspense,
        label: 'Thrilled',
        description: 'Ready for suspense',
      ),
      MoodSuggestion(
        mood: Mood.introspective,
        label: 'Reflective',
        description: 'In a contemplative mood',
      ),
    ];
  }

  return const [
    MoodSuggestion(
      mood: Mood.relaxed,
      label: 'Peaceful',
      description: 'Something calming',
    ),
    MoodSuggestion(
      mood: Mood.introspective,
      label: 'Deep',
      description: 'Want to think deeply',
    ),
    MoodSuggestion(
      mood: Mood.romantic,
      label: 'Romantic',
      description: 'Perfect for a date night',
    ),
  ];
}
