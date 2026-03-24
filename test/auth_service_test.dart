import 'package:flutter_test/flutter_test.dart';
import 'package:couple_front/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('AuthService.getErrorMessage', () {
    test('returns correct message for user-not-found', () {
      final e = FirebaseAuthException(code: 'user-not-found');
      expect(
        AuthService.getErrorMessage(e),
        'No account found with this email.',
      );
    });

    test('returns correct message for wrong-password', () {
      final e = FirebaseAuthException(code: 'wrong-password');
      expect(
        AuthService.getErrorMessage(e),
        'Incorrect password. Please try again.',
      );
    });

    test('returns correct message for email-already-in-use', () {
      final e = FirebaseAuthException(code: 'email-already-in-use');
      expect(
        AuthService.getErrorMessage(e),
        'An account already exists with this email.',
      );
    });

    test('returns correct message for invalid-email', () {
      final e = FirebaseAuthException(code: 'invalid-email');
      expect(
        AuthService.getErrorMessage(e),
        'Please enter a valid email address.',
      );
    });

    test('returns correct message for weak-password', () {
      final e = FirebaseAuthException(code: 'weak-password');
      expect(
        AuthService.getErrorMessage(e),
        'Password should be at least 6 characters.',
      );
    });

    test('returns correct message for too-many-requests', () {
      final e = FirebaseAuthException(code: 'too-many-requests');
      expect(
        AuthService.getErrorMessage(e),
        'Too many attempts. Please try again later.',
      );
    });

    test('returns firebase message for unknown codes', () {
      final e = FirebaseAuthException(
        code: 'unknown-code',
        message: 'Some specific firebase message',
      );
      expect(
        AuthService.getErrorMessage(e),
        'Some specific firebase message',
      );
    });

    test('returns fallback for unknown codes with no message', () {
      final e = FirebaseAuthException(code: 'unknown-code');
      expect(
        AuthService.getErrorMessage(e),
        'An error occurred. Please try again.',
      );
    });
  });
}
