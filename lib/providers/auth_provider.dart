import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthResult {
  const AuthResult._(this.success, this.message, this.cancelled);
  const AuthResult.ok([String? message]) : this._(true, message, false);
  const AuthResult.failure(String message) : this._(false, message, false);
  const AuthResult.cancelled() : this._(false, null, true);

  final bool success;
  final String? message;
  final bool cancelled;
}

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _user = _service.currentUser;
    _sub = _service.userChanges.listen((u) {
      _user = u;
      _initializing = false;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<User?> _sub;

  User? _user;
  bool _initializing = true;

  User? get user => _user;
  bool get initializing => _initializing;
  bool get isAuthenticated => _user != null;

  Future<AuthResult> signIn({required String email, required String password}) =>
      _run(() => _service.signIn(email: email, password: password));

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(() => _service.signUp(name: name, email: email, password: password));

  Future<AuthResult> signInWithGoogle() async {
    try {
      final signedIn = await _service.signInWithGoogle();
      return signedIn ? const AuthResult.ok() : const AuthResult.cancelled();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e));
    } catch (_) {
      return const AuthResult.failure(
        'Google sign-in failed. Check your connection and Firebase SHA-1 setup.',
      );
    }
  }

  Future<AuthResult> sendPasswordReset(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<AuthResult> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _service.verifyResetCode(code);
      await _service.confirmPasswordReset(code: code, newPassword: newPassword);
      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e));
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut() => _service.signOut();

  Future<AuthResult> _run(Future<void> Function() action) async {
    try {
      await action();
      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e));
    } catch (_) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      case 'expired-action-code':
        return 'That reset code has expired. Request a new one.';
      case 'invalid-action-code':
        return 'That reset code is invalid or already used.';
      case 'account-exists-with-different-credential':
        return 'An account exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
