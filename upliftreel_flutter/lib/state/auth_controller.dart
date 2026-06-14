import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../domain/models/auth_user.dart';
import 'providers.dart';

/// Session state for the whole app: AsyncData(user) = authenticated,
/// AsyncData(null) = signed out, AsyncLoading/AsyncError during commands.
/// On a command error the state holds the AuthFailure (read via state.error)
/// so the UI can surface a message; the previous session is re-asserted by
/// the authStateChanges subscription, which only fires on real changes.
class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    if (!repository.isConfigured) return null;

    // Push every external session change (OAuth deep link, token refresh,
    // expiry) into state; commands below also set state directly.
    final subscription = repository.authStateChanges().listen(
      (user) => state = AsyncData(user),
    );
    ref.onDispose(subscription.cancel);

    return repository.currentUser;
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) => _run((repository) async {
    await repository.signInWithEmail(email: email, password: password);
    return repository.currentUser;
  });

  /// Returns null on failure; with email confirmation enabled the result is
  /// [SignUpResult.confirmationEmailSent] and state stays signed out — the
  /// caller surfaces the "check your inbox" message.
  Future<SignUpResult?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading<AuthUser?>();
    final result = await AsyncValue.guard(
      () => repository.signUpWithEmail(email: email, password: password),
    );
    return result.when(
      data: (signUpResult) {
        state = AsyncData(repository.currentUser);
        return signUpResult;
      },
      error: (error, stackTrace) {
        state = AsyncError<AuthUser?>(error, stackTrace);
        return null;
      },
      loading: () => null,
    );
  }

  /// Launches the browser flow; the session arrives later through the
  /// authStateChanges subscription, so success here only means "launched".
  Future<bool> signInWithGoogle() => _run((repository) async {
    await repository.signInWithGoogle();
    return repository.currentUser;
  });

  Future<bool> signOut() => _run((repository) async {
    await repository.signOut();
    return null;
  });

  Future<bool> _run(
    Future<AuthUser?> Function(AuthRepository repository) command,
  ) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading<AuthUser?>();
    final result = await AsyncValue.guard(() => command(repository));
    state = result;
    return !result.hasError;
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);
