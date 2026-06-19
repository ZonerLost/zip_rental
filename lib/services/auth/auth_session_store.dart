import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionStore {
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _pendingEmailKey = 'auth_pending_email';
  static const _pendingPhoneKey = 'auth_pending_phone';
  static const _tokenExpiryKey = 'auth_token_expiry_ms';
  static const _languageKey = 'user_language_preference';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    Duration ttl = const Duration(minutes: 15),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    await prefs.setInt(
      _tokenExpiryKey,
      DateTime.now().add(ttl).millisecondsSinceEpoch,
    );
  }

  /// Returns the stored access token only if it has more than [_earlyExpiry]
  /// remaining. Returns null if expired or near-expiry, forcing a refresh.
  static const Duration _earlyExpiry = Duration(minutes: 1);

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_tokenExpiryKey);
    if (expiryMs != null) {
      final remaining =
          DateTime.fromMillisecondsSinceEpoch(expiryMs).difference(DateTime.now());
      if (remaining <= _earlyExpiry) return null;
    }
    return prefs.getString(_accessTokenKey);
  }

  /// Returns the raw stored token regardless of expiry.
  /// Use only when you need the token for non-API purposes (e.g. logout body).
  Future<String?> getRawAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Returns remaining time until the stored access token expires.
  /// Returns [Duration.zero] if already expired or no expiry recorded.
  Future<Duration> remainingTokenLife() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_tokenExpiryKey);
    if (expiryMs == null) return Duration.zero;
    final remaining =
        DateTime.fromMillisecondsSinceEpoch(expiryMs).difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  Future<void> savePendingEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email);
  }

  Future<String?> getPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  Future<void> clearPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
  }

  Future<void> savePendingPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingPhoneKey, phone);
  }

  Future<String?> getPendingPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingPhoneKey);
  }

  Future<void> clearPendingPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingPhoneKey);
  }

  Future<void> saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }
}
