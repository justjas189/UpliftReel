/// Legacy formatRuntime: "2h 28m" / "45m".
String formatRuntime(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  return hours > 0 ? '${hours}h ${remainder}m' : '${remainder}m';
}

/// Legacy titleCase for genre labels: "sci-fi" → "Sci-Fi".
String titleCase(String value) {
  return value
      .split('-')
      .map((part) =>
          part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
      .join('-');
}
