import 'user_preferences.dart';

/// Transient, session-only release-era overlay for recommendations.
///
/// Distinct from the persisted [UserPreferences.releaseYearRange]: the Era
/// Selector is a quick, non-destructive filter the user flips on the home
/// screen ("show me 2010s movies tonight") without editing their saved
/// profile. It is never persisted — picking a new mood/day resets nothing,
/// but it also doesn't survive an app restart, by design.
///
/// [minYear]/[maxYear] are inclusive bounds; null means "open on that side".
/// [EraFilter.all] (both null) disables filtering.
class EraFilter {
  const EraFilter({required this.label, this.minYear, this.maxYear});

  final String label;
  final int? minYear;
  final int? maxYear;

  /// No release-date constraint.
  static const EraFilter all = EraFilter(label: 'All years');

  /// Curated decade presets, newest first. Open-ended on the top so a preset
  /// like "2020s" keeps matching as years roll forward.
  static const List<EraFilter> presets = [
    all,
    EraFilter(label: '2020s', minYear: 2020),
    EraFilter(label: '2010s', minYear: 2010, maxYear: 2019),
    EraFilter(label: '2000s', minYear: 2000, maxYear: 2009),
    EraFilter(label: '90s', minYear: 1990, maxYear: 1999),
    EraFilter(label: '80s', minYear: 1980, maxYear: 1989),
    EraFilter(label: 'Classics', maxYear: 1979),
  ];

  bool get isAll => minYear == null && maxYear == null;

  /// Engine-facing year range, intersected later with the persisted
  /// preference range by the engine's hard filter. Null when [isAll].
  ReleaseYearRange? toRange() {
    if (isAll) return null;
    return ReleaseYearRange(
      min: minYear ?? 1900,
      max: maxYear ?? DateTime.now().year,
    );
  }

  /// Builds a custom range from a user-picked span; clamps the order so a
  /// reversed pick can't produce an empty filter.
  factory EraFilter.custom({required int from, required int to}) {
    final lo = from <= to ? from : to;
    final hi = from <= to ? to : from;
    return EraFilter(label: '$lo–$hi', minYear: lo, maxYear: hi);
  }

  @override
  bool operator ==(Object other) =>
      other is EraFilter &&
      other.minYear == minYear &&
      other.maxYear == maxYear;

  @override
  int get hashCode => Object.hash(minYear, maxYear);
}
