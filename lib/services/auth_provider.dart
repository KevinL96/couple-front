import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading();
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> registerWithEmail(
      String email, String password, String displayName) async {
    _setLoading();
    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
      return false;
    } catch (_) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
      return false;
    } catch (_) {
      _setError('Google sign-in failed. Please try again.');
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      _setStatus(AuthStatus.unauthenticated);
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.getErrorMessage(e));
    } catch (_) {
      _setError('Failed to send reset email.');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading() {
    _errorMessage = null;
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}
