import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upliftreel/data/repositories/auth_repository.dart';
import 'package:upliftreel/domain/models/auth_failure.dart';
import 'package:upliftreel/state/auth_controller.dart';
import 'package:upliftreel/state/providers.dart';

import 'fake_auth_repository.dart';

const _user = kFakeAuthUser;

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    repository = FakeAuthRepository();
    container = makeContainer();
  });

  test('build resolves to null when Supabase is not configured', () async {
    repository = FakeAuthRepository(configured: false);
    container = makeContainer();

    expect(await container.read(authControllerProvider.future), isNull);
  });

  test('build resolves to the existing session user', () async {
    repository.user = _user;
    expect(await container.read(authControllerProvider.future), _user);
  });

  test('signInWithEmail success lands in AsyncData(user)', () async {
    await container.read(authControllerProvider.future);

    final ok = await container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'jasper@example.com', password: 'secret1');

    expect(ok, isTrue);
    expect(container.read(authControllerProvider).value, _user);
  });

  test(
    'signInWithEmail failure exposes AuthFailure and keeps prior value',
    () async {
      await container.read(authControllerProvider.future);
      repository.nextFailure = const AuthFailure('Invalid login credentials');

      final ok = await container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'jasper@example.com', password: 'wrong');

      final state = container.read(authControllerProvider);
      expect(ok, isFalse);
      expect(state.hasError, isTrue);
      expect(state.error, isA<AuthFailure>());
      expect(
        state.value,
        isNull,
      ); // copyWithPrevious kept the signed-out value.
    },
  );

  test(
    'signUpWithEmail reports confirmation-email-sent without a session',
    () async {
      await container.read(authControllerProvider.future);
      repository.signUpResult = SignUpResult.confirmationEmailSent;

      final result = await container
          .read(authControllerProvider.notifier)
          .signUpWithEmail(email: 'new@example.com', password: 'secret1');

      expect(result, SignUpResult.confirmationEmailSent);
      expect(container.read(authControllerProvider).value, isNull);
    },
  );

  test('OAuth deep-link session arrives through the auth stream', () async {
    await container.read(authControllerProvider.future);

    final ok = await container
        .read(authControllerProvider.notifier)
        .signInWithGoogle();
    expect(ok, isTrue);
    expect(container.read(authControllerProvider).value, isNull);

    repository.emit(_user); // Browser round-trip completes.
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, _user);
  });

  test('signOut clears the user', () async {
    repository.user = _user;
    await container.read(authControllerProvider.future);

    final ok = await container.read(authControllerProvider.notifier).signOut();

    expect(ok, isTrue);
    expect(container.read(authControllerProvider).value, isNull);
  });
}
