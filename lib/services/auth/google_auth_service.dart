import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Replace with your Web OAuth 2.0 Client ID from Google Cloud Console
  // APIs & Services → Credentials → Web application client ID
  static const String _webClientId =
      '112360729895-pfbkvn8kav52rrr82tcrk0g3a400mdbl.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;

  Future<String?> getIdToken() async {
    await _ensureInitialized();
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) return null;
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!_isInitialized) return;
    await _googleSignIn.signOut();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _googleSignIn.initialize(serverClientId: _webClientId);
    _isInitialized = true;
  }
}
