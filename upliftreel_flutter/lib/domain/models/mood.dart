import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood.freezed.dart';
part 'mood.g.dart';

/// The eight legacy moods. Legacy `MoodEmoji` used the emoji character as
/// enum identity; here the name is the identity and the emoji is data.
/// Aligns 1:1 with StitchMood in the theme layer (which adds `neutral`).
enum Mood {
  @JsonValue('happy')
  happy('😊', 'Happy'),
  @JsonValue('suspense')
  suspense('😨', 'Suspense'),
  @JsonValue('introspective')
  introspective('😔', 'Introspective'),
  @JsonValue('excited')
  excited('🤩', 'Excited'),
  @JsonValue('romantic')
  romantic('😍', 'Romantic'),
  @JsonValue('adventurous')
  adventurous('🏃‍♂️', 'Adventurous'),
  @JsonValue('relaxed')
  relaxed('😌', 'Relaxed'),
  @JsonValue('curious')
  curious('🤔', 'Curious');

  const Mood(this.emoji, this.label);
  final String emoji;
  final String label;
}

@freezed
abstract class MoodInput with _$MoodInput {
  const factory MoodInput({
    required Mood mood,

    /// 1–10.
    required int intensity,

    /// 1 = fun … 10 = serious. Was `moodSlider` in legacy.
    required int seriousness,
  }) = _MoodInput;

  factory MoodInput.fromJson(Map<String, dynamic> json) =>
      _$MoodInputFromJson(json);
}
