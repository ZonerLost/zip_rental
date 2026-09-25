import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Access/refresh tokens live in the platform Keychain/EncryptedSharedPreferences
/// via [FlutterSecureStorage] — not plain [SharedPreferences], which is
/// unencrypted on both Android and iOS. Non-sensitive session bookkeeping
/// (pending email/phone for OTP flows, language preference) stays in
/// SharedPreferences since it isn't a credential and should clear normally
/// on uninstall.
class AuthSessionStore {
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _tokenExpiryKey = 'auth_token_expiry_ms';
  static const _pendingEmailKey = 'auth_pending_email';
  static const _pendingPhoneKey = 'auth_pending_phone';
  static const _languageKey = 'user_language_preference';
  static const _initialSetupCompleteKey = 'has_completed_initial_setup';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// One-time move of any pre-existing tokens from the old SharedPreferences
  /// store into secure storage, so upgrading the app doesn't silently sign
  /// everyone out. Memoized so it only runs once per process no matter how
  /// many AuthSessionStore instances call into it, and every public method
  /// below awaits it first to avoid a fresh save racing a late migration.
  static Future<void>? _migrationFuture;

  Future<void> _ensureMigrated() {
    return _migrationFuture ??= _migrateLegacyTokens();
  }

  Future<void> _migrateLegacyTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacyAccess = prefs.getString(_accessTokenKey);
      final legacyRefresh = prefs.getString(_refreshTokenKey);
      final legacyExpiry = prefs.getInt(_tokenExpiryKey);

      if (legacyAccess == null && legacyRefresh == null && legacyExpiry == null) {
        return;
      }

      if (legacyAccess != null && legacyAccess.isNotEmpty) {
        await _secureStorage.write(key: _accessTokenKey, value: legacyAccess);
      }
      if (legacyRefresh != null && legacyRefresh.isNotEmpty) {
        await _secureStorage.write(key: _refreshTokenKey, value: legacyRefresh);
      }
      if (legacyExpiry != null) {
        await _secureStorage.write(
          key: _tokenExpiryKey,
          value: legacyExpiry.toString(),
        );
      }

      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiryKey);
    } catch (_) {
      // Best-effort: if this fails, the legacy prefs entries are just
      // ignored and the user needs to sign in again once, not stuck.
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    Duration ttl = const Duration(minutes: 15),
  }) async {
    await _ensureMigrated();
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
    await _secureStorage.write(
      key: _tokenExpiryKey,
      value: DateTime.now().add(ttl).millisecondsSinceEpoch.toString(),
    );
    // A saved token means a real account exists on this device now, so the
    // first-run language/onboarding screens have served their purpose.
    await markInitialSetupComplete();
  }

  /// Returns the stored access token only if it has more than [_earlyExpiry]
  /// remaining. Returns null if expired or near-expiry, forcing a refresh.
  static const Duration _earlyExpiry = Duration(minutes: 1);

  Future<String?> getAccessToken() async {
    await _ensureMigrated();
    final expiryMs = await _readExpiryMs();
    if (expiryMs != null) {
      final remaining = DateTime.fromMillisecondsSinceEpoch(
        expiryMs,
      ).difference(DateTime.now());
      if (remaining <= _earlyExpiry) return null;
    }
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Returns the raw stored token regardless of expiry.
  /// Use only when you need the token for non-API purposes (e.g. logout body).
  Future<String?> getRawAccessToken() async {
    await _ensureMigrated();
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    await _ensureMigrated();
    return _secureStorage.read(key: _refreshTokenKey);
  }

  /// Returns remaining time until the stored access token expires.
  /// Returns [Duration.zero] if already expired or no expiry recorded.
  Future<Duration> remainingTokenLife() async {
    await _ensureMigrated();
    final expiryMs = await _readExpiryMs();
    if (expiryMs == null) return Duration.zero;
    final remaining = DateTime.fromMillisecondsSinceEpoch(
      expiryMs,
    ).difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<int?> _readExpiryMs() async {
    final raw = await _secureStorage.read(key: _tokenExpiryKey);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> clearTokens() async {
    await _ensureMigrated();
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
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

  /// True once an account has been created or logged into on this device —
  /// after that, the first-run language-picker + onboarding screens should
  /// no longer be shown; a logged-out user should land straight on Login.
  Future<bool> hasCompletedInitialSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initialSetupCompleteKey) ?? false;
  }

  Future<void> markInitialSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initialSetupCompleteKey, true);
  }
}
