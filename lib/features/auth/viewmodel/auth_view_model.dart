import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ViewModel für Authentication
///
/// Verwaltet den State für Login/Register und Anbindung an Firebase Auth + Firestore.
/// Fehlercodes für Auth-Fehler (werden in der UI übersetzt).
class AuthErrorCode {
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String invalidEmail = 'invalid-email';
  static const String weakPassword = 'weak-password';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String registrationFailed = 'registration-failed';
}

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error, {String? code}) {
    _errorMessage = error;
    _errorCode = code;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  /// Registriert einen Nutzer per E-Mail/Passwort, speichert Profil in Firestore.
  /// [email] E-Mail-Adresse
  /// [password] Passwort (min. 8 Zeichen)
  /// [displayName] Anzeigename
  /// Gibt die User-ID zurück bei Erfolg, wirft bei Fehler.
  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    clearError();
    setLoading(true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      final user = credential.user;
      if (user == null) {
        setError(null, code: AuthErrorCode.registrationFailed);
        return null;
      }

      await user.updateDisplayName(displayName.trim());

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      setLoading(false);
      return user.uid;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      switch (e.code) {
        case 'email-already-in-use':
          setError(null, code: AuthErrorCode.emailAlreadyInUse);
          break;
        case 'invalid-email':
          setError(null, code: AuthErrorCode.invalidEmail);
          break;
        case 'weak-password':
          setError(null, code: AuthErrorCode.weakPassword);
          break;
        case 'operation-not-allowed':
          setError(null, code: AuthErrorCode.operationNotAllowed);
          break;
        default:
          setError(null, code: AuthErrorCode.registrationFailed);
      }
      return null;
    } catch (e) {
      setLoading(false);
      setError(null, code: AuthErrorCode.registrationFailed);
      return null;
    }
  }

  /// Anmeldung per E-Mail/Passwort.
  /// Gibt bei Erfolg die User-ID zurück, sonst null.
  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    clearError();
    setLoading(true);
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      setLoading(false);
      return user?.uid;
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          setError(null, code: AuthErrorCode.invalidEmail);
          break;
        case 'invalid-email':
          setError(null, code: AuthErrorCode.invalidEmail);
          break;
        case 'user-disabled':
          setError(null, code: AuthErrorCode.registrationFailed);
          break;
        default:
          setError(null, code: AuthErrorCode.registrationFailed);
      }
      return null;
    } catch (e) {
      setLoading(false);
      setError(null, code: AuthErrorCode.registrationFailed);
      return null;
    }
  }
}
