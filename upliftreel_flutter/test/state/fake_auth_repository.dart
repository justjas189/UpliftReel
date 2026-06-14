import 'dart:async';

import 'package:upliftreel/data/repositories/auth_repository.dart';
import 'package:upliftreel/domain/models/auth_failure.dart';
import 'package:upliftreel/domain/models/auth_user.dart';

/// Successful sign-ins resolve to this account.
const kFakeAuthUser = AuthUser(
  id: 'uid-1',
  email: 'jasper@example.com',
  displayName: 'Jasper',
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.configured = true, this.user});

  final bool configured;
  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();

  AuthUser? user;
  AuthFailure? nextFailure;
  SignUpResult signUpResult = SignUpResult.signedIn;

  /// Simulates an external session event (OAuth deep-link return, expiry).
  void emit(AuthUser? next) {
    user = next;
    _changes.add(next);
  }

  void _throwIfFailing() {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
  }

  @override
  bool get isConfigured => configured;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> authStateChanges() => _changes.stream;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _throwIfFailing();
    user = kFakeAuthUser;
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _throwIfFailing();
    if (signUpResult == SignUpResult.signedIn) user = kFakeAuthUser;
    return signUpResult;
  }

  @override
  Future<void> signInWithGoogle() async {
    _throwIfFailing();
    // Real flow: browser launches, session arrives later via emit().
  }

  @override
  Future<void> signOut() async {
    _throwIfFailing();
    user = null;
  }
}
