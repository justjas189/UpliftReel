import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/mood.dart';
import '../ui/core/theme/stitch_mood_theme.dart';
import 'providers.dart';

/// Current mood selection. Null means the user hasn't set one today —
/// recommendations then run on preferences alone (legacy semantics).
///
/// [select] updates state only (live ambience preview while browsing moods);
/// [commit] writes the selection to mood history — call it once at submit,
/// not on every card tap.
class MoodController extends Notifier<MoodInput?> {
  @override
  MoodInput? build() => null;

  void select(MoodInput input) => state = input;

  Future<void> commit() async {
    final input = state;
    if (input == null) return;
    await ref.read(moodRepositoryProvider).logMood(input);
  }

  void clear() => state = null;
}

final moodControllerProvider =
    NotifierProvider<MoodController, MoodInput?>(MoodController.new);

/// Bridges the domain mood to the theme's ambience state — the wire that
/// makes picking a mood recolor the whole app.
final stitchMoodProvider = Provider<StitchMood>((ref) {
  final mood = ref.watch(moodControllerProvider)?.mood;
  return mood == null ? StitchMood.neutral : stitchMoodFor(mood);
});
