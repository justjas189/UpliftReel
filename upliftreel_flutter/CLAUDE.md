# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

UpliftReel: mood-based daily movie recommendation app. Flutter port of the legacy React Native app in the parent directory (`../`); the port is feature-complete except notifications and year-range preference UI (deferred backlog). The recommendation engine is a behavior-parity port of the legacy TypeScript engine — tests assert exact legacy scoring weights (genre 40 + rating 20 + people 15 + mood 15 + runtime 10), so don't "improve" weights without updating parity tests deliberately.

## Commands

- Test: `flutter test` · Analyze: `flutter analyze`
- Codegen (after touching freezed/json models): `dart run build_runner build --delete-conflicting-outputs`
- Run with API keys: `flutter run --dart-define-from-file=dart-defines.json` (gitignored file with `TMDB_ACCESS_TOKEN` and `OMDB_API_KEY`; read via `String.fromEnvironment` in `lib/data/services/api_config.dart`)

## Architecture

Layered: `lib/data` (services wrap TMDB/OMDb APIs, repositories return domain models) → `lib/domain` (freezed models + `RecommendationEngine`) → `lib/state` (Riverpod controllers = ViewModels) → `lib/ui` (feature-grouped views + `ui/core` theme/widgets).

- UI never imports `lib/data` directly — go through `lib/state` providers; shared types live in `lib/domain/models`.
- Infrastructure providers (Hive boxes, SharedPreferences) throw `UnimplementedError` unless overridden in `ProviderScope` at boot (`main.dart`); tests must override them.

## Testing gotchas

- Widget tests: memory-backed Hive boxes (`bytes: Uint8List(0)`), `SharedPreferences.setMockInitialValues({})`, `GoogleFonts.config.allowRuntimeFetching = false` in `setUpAll`.
- Use fixed `pump()` calls, not `pumpAndSettle()` — fire-and-forget Hive writes deadlock teardown otherwise.
- HTTP stubbing: `test/data/fake_http_adapter.dart` (custom Dio `HttpClientAdapter`), no network in tests.

## Conventions

- Commit directly to `main` — no feature branches or PRs.
- Lint deviation: `prefer_initializing_formals: false` (DI uses named params assigned to private fields).
