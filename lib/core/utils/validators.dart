import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? name(String? v) {
    if (v == null || v.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email address';
    if (!_email.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < AppConstants.minPasswordLength) {
      return 'Use at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? loginPassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter your password';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? v, String message) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }

  /// Returns a score from 0 (empty) to 4 (strong).
  static int passwordStrength(String v) {
    if (v.isEmpty) return 0;
    var score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(v) && RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'\d').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    return score;
  }
}
