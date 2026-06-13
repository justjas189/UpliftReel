import 'movie.dart';

/// One renderable history row. Legacy assembled these against the 5-movie
/// sample DB, so live TMDB picks silently vanished from history; snapshots
/// stored at recommendation time make every row resolvable.
class HistoryEntry {
  const HistoryEntry({
    required this.movie,
    required this.date,
    required this.isRecommendation,
    required this.isWatched,
    this.matchScore,
  });

  final Movie movie;
  final DateTime date;
  final bool isRecommendation;
  final bool isWatched;
  final double? matchScore;
}
