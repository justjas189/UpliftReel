import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upliftreel/data/repositories/preferences_repository.dart';
import 'package:upliftreel/domain/models/movie.dart';
import 'package:upliftreel/domain/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = PreferencesRepository(await SharedPreferences.getInstance());
  });

  group('validate (legacy clamp parity)', () {
    test('empty genres fall back to comedy+drama', () {
      final result = repository.validate(
        UserPreferences.defaults().copyWith(selectedGenres: []),
      );
      expect(result.selectedGenres, [Genre.comedy, Genre.drama]);
    });

    test('ratings clamp to 1–10 and keep min <= max', () {
      final result = repository.validate(
        UserPreferences.defaults().copyWith(minRating: 0, maxRating: 12),
      );
      expect(result.minRating, 1.0);
      expect(result.maxRating, 10.0);

      final inverted = repository.validate(
        UserPreferences.defaults().copyWith(minRating: 9, maxRating: 7),
      );
      expect(inverted.maxRating, 9.0);
    });

    test('year range clamps to 1900–currentYear', () {
      final result = repository.validate(
        UserPreferences.defaults().copyWith(
          releaseYearRange: const ReleaseYearRange(min: 1800, max: 3000),
        ),
      );
      expect(result.releaseYearRange!.min, 1900);
      expect(result.releaseYearRange!.max, DateTime.now().year);
    });

    test('runtime clamps to 30–300 minutes', () {
      final low = repository.validate(
        UserPreferences.defaults().copyWith(maxRuntime: 5),
      );
      expect(low.maxRuntime, 30);

      final high = repository.validate(
        UserPreferences.defaults().copyWith(maxRuntime: 500),
      );
      expect(high.maxRuntime, 300);
    });

    test('unknown preferred language resets to en', () {
      final result = repository.validate(
        UserPreferences.defaults().copyWith(preferredLanguage: 'xx'),
      );
      expect(result.preferredLanguage, 'en');

      final valid = repository.validate(
        UserPreferences.defaults().copyWith(preferredLanguage: 'tl'),
      );
      expect(valid.preferredLanguage, 'tl');
    });

    test('invalid notification time resets to 19:00', () {
      final result = repository.validate(
        UserPreferences.defaults().copyWith(notificationTime: '25:99'),
      );
      expect(result.notificationTime, '19:00');

      final valid = repository.validate(
        UserPreferences.defaults().copyWith(notificationTime: '08:30'),
      );
      expect(valid.notificationTime, '08:30');
    });
  });

  group('persistence', () {
    test('first load saves and returns defaults', () async {
      final loaded = await repository.load();
      expect(loaded.selectedGenres, [Genre.comedy, Genre.drama, Genre.action]);

      final reloaded = await repository.load();
      expect(reloaded, loaded);
    });

    test('save then load round-trips', () async {
      final custom = UserPreferences.defaults().copyWith(
        selectedGenres: [Genre.horror, Genre.mystery],
        minRating: 7.5,
        notificationTime: '21:00',
      );

      await repository.save(custom);
      final loaded = await repository.load();

      expect(loaded.selectedGenres, [Genre.horror, Genre.mystery]);
      expect(loaded.minRating, 7.5);
      expect(loaded.notificationTime, '21:00');
    });

    test('corrupted storage falls back to defaults', () async {
      SharedPreferences.setMockInitialValues({'user_preferences': 'not json{'});
      final repo = PreferencesRepository(await SharedPreferences.getInstance());

      final loaded = await repo.load();

      expect(loaded.minRating, 6.0);
    });
  });
}
