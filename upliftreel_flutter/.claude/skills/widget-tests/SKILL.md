---
name: widget-tests
description: Conventions for writing widget/UI tests in this repo. Use whenever creating or modifying tests under test/ui/ or any testWidgets test, to follow the required Hive/SharedPreferences/GoogleFonts bootstrap and avoid the known pumpAndSettle deadlock.
---

# Writing widget tests in this repo

Follow the established pattern (reference: `test/widget_test.dart`, `test/ui/*_test.dart`). Tests run fully offline.

## Required bootstrap

1. `TestWidgetsFlutterBinding.ensureInitialized();` at top of `main()`.
2. `setUpAll`: `GoogleFonts.config.allowRuntimeFetching = false;` — no network font fetch.
3. `setUp`: init Hive in a temp dir and open **memory-backed** boxes:
   ```dart
   Hive.init(tempDir.path);
   box = await Hive.openBox<String>('name', bytes: Uint8List(0));
   ```
   `bytes: Uint8List(0)` is mandatory — a real file write started inside the testWidgets FakeAsync zone can never complete after the test body ends and deadlocks teardown on the box's write lock.
4. `SharedPreferences.setMockInitialValues({});` then `getInstance()`.
5. `tearDown`: `await Hive.close();` then delete the temp dir.

## Provider overrides

Wrap the widget under test in `ProviderScope` and override ALL infrastructure providers from `lib/state/providers.dart` (`sharedPreferencesProvider`, `movieCacheBoxProvider`, `historyBoxProvider`, `moodBoxProvider`, `tmdbApiProvider`, `omdbApiProvider`) — they throw `UnimplementedError` if not overridden.

## HTTP stubbing

Never hit the network. Use `test/data/fake_http_adapter.dart`:

```dart
final offline = FakeHttpAdapter((_) => jsonResponse('{"results": []}'));
TmdbApi(dio: Dio()..httpClientAdapter = offline, accessToken: 'token')
```

## Pumping — critical

Do NOT use `pumpAndSettle()` — it can spin forever when a fire-and-forget Hive write holds a pending real-IO future. Use fixed pumps:

```dart
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}
```

## Verify

Run with `C:/flutter/bin/flutter test <file>` (SDK not on PATH).
