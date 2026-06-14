import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/models/auth_failure.dart';
import '../../../../state/auth_controller.dart';
import '../../../core/theme/stitch_theme.dart';
import '../../../core/widgets/stitch_button.dart';

/// Stitch 2.0 login surface: modal bottom sheet with Google OAuth and an
/// email/password form that toggles between sign-in and create-account.
/// Pops itself as soon as the auth controller reports a session (covers
/// both the password flow and the async OAuth deep-link return).
Future<void> showAuthSheet(BuildContext context) {
  final colors = StitchColors.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.charcoal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(StitchRadius.lg),
      ),
    ),
    builder: (context) => const _AuthSheet(),
  );
}

enum _AuthMode { signIn, createAccount }

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet();

  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  String? _error;
  bool _confirmationEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = _emailController.text.trim();
    if (!email.contains('@') || email.length < 5) {
      return 'Enter a valid email address.';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  Future<void> _submitEmailPassword() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() {
        _error = validationError;
        _confirmationEmailSent = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _confirmationEmailSent = false;
    });

    final controller = ref.read(authControllerProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_mode == _AuthMode.signIn) {
      final ok = await controller.signInWithEmail(
        email: email,
        password: password,
      );
      if (!ok) _showStateError();
    } else {
      final result = await controller.signUpWithEmail(
        email: email,
        password: password,
      );
      if (result == null) {
        _showStateError();
      } else if (result == SignUpResult.confirmationEmailSent && mounted) {
        setState(() => _confirmationEmailSent = true);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _error = null;
      _confirmationEmailSent = false;
    });
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();
    if (!ok) _showStateError();
  }

  void _showStateError() {
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    setState(() {
      _error = switch (error) {
        AuthFailure(:final message) => message,
        _ => 'Something went wrong. Please try again.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    // Close once a session exists — email sign-in or OAuth deep-link return.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.value != null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final authState = ref.watch(authControllerProvider);
    final loading = authState.isLoading;
    final isSignIn = _mode == _AuthMode.signIn;

    return Padding(
      // Keep the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          StitchSpacing.xl,
          StitchSpacing.md,
          StitchSpacing.xl,
          StitchSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.hairline,
                  borderRadius: BorderRadius.circular(StitchRadius.full),
                ),
              ),
            ),
            const SizedBox(height: StitchSpacing.lg),
            Text(
              isSignIn ? 'Welcome back' : 'Create your account',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: StitchSpacing.xs),
            Text(
              'Sync your movie journey across devices.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: StitchSpacing.xl),
            StitchButton(
              label: 'Continue with Google',
              icon: Icons.g_mobiledata,
              variant: StitchButtonVariant.outline,
              expand: true,
              loading: loading,
              onPressed: loading ? null : _signInWithGoogle,
            ),
            const SizedBox(height: StitchSpacing.lg),
            Row(
              children: [
                Expanded(child: Divider(color: colors.hairline)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StitchSpacing.md,
                  ),
                  child: Text('OR', style: textTheme.labelSmall),
                ),
                Expanded(child: Divider(color: colors.hairline)),
              ],
            ),
            const SizedBox(height: StitchSpacing.lg),
            _AuthField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: StitchSpacing.md),
            _AuthField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              onSubmitted: (_) => _submitEmailPassword(),
            ),
            if (_error != null) ...[
              const SizedBox(height: StitchSpacing.md),
              Text(
                _error!,
                style: textTheme.bodyMedium?.copyWith(color: colors.danger),
                textAlign: TextAlign.center,
              ),
            ],
            if (_confirmationEmailSent) ...[
              const SizedBox(height: StitchSpacing.md),
              Text(
                'Almost there — check your inbox to confirm your email, '
                'then sign in.',
                style: textTheme.bodyMedium?.copyWith(color: colors.success),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: StitchSpacing.lg),
            StitchButton(
              label: isSignIn ? 'Sign in' : 'Create account',
              variant: StitchButtonVariant.mood,
              expand: true,
              loading: loading,
              onPressed: loading ? null : _submitEmailPassword,
            ),
            const SizedBox(height: StitchSpacing.md),
            GestureDetector(
              onTap: loading
                  ? null
                  : () => setState(() {
                      _mode = isSignIn
                          ? _AuthMode.createAccount
                          : _AuthMode.signIn;
                      _error = null;
                      _confirmationEmailSent = false;
                    }),
              child: Text.rich(
                TextSpan(
                  text: isSignIn
                      ? 'New to Uplift Reel? '
                      : 'Already have an account? ',
                  style: textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: isSignIn ? 'Create an account' : 'Sign in',
                      style: textTheme.bodyMedium?.copyWith(
                        color: moodTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = StitchColors.of(context);
    final moodTheme = StitchMoodTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      style: textTheme.bodyLarge,
      cursorColor: moodTheme.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.smoke),
        prefixIcon: Icon(icon, size: 20, color: colors.smoke),
        filled: true,
        fillColor: colors.graphite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.base,
          vertical: StitchSpacing.base,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StitchRadius.md),
          borderSide: BorderSide(color: colors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StitchRadius.md),
          borderSide: BorderSide(color: moodTheme.accent),
        ),
      ),
    );
  }
}
