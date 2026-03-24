import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInitialization;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register with email and password.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }
    return credential;
  }

  /// Sign in with Google.
  Future<UserCredential?> signInWithGoogle() async {
    _googleInitialization ??= _googleSignIn.initialize();
    await _googleInitialization;
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // User cancelled
      }
      rethrow;
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    return _auth.signInWithCredential(credential);
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Returns a human-readable error message for Firebase exceptions.
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
