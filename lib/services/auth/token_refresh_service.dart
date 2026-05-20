import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/config/api/api_config.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_session_store.dart';

/// Registered as a GetxService so it survives navigation and is never
/// garbage-collected while the app is running.
///
/// Lifecycle:
///   TokenRefreshService.start()  — call after login / on app launch with session
///   TokenRefreshService.stop()   — call on logout
///
/// Offline safety:
///   If the device is offline when a refresh is due, the call is silently
///   skipped and retried every [_retryInterval] until it succeeds, at which
///   point the normal [_refreshInterval] cadence resumes.
class TokenRefreshService extends GetxService {
  static const Duration _refreshInterval = Duration(minutes: 14);
  static const Duration _retryInterval = Duration(minutes: 2);
  // Refresh 1 min before expiry when scheduling from a known remaining life.
  static const Duration _earlyBuffer = Duration(minutes: 1);

  final AuthSessionStore _store;

  // Lazily-built HTTP client — avoids importing AuthService (circular dep).
  late final _RefreshClient _client;

  Timer? _timer;
  bool _running = false;

  TokenRefreshService({AuthSessionStore? store})
      : _store = store ?? AuthSessionStore() {
    _client = _RefreshClient(ApiConfig.baseUrl);
  }

  // ── public API ────────────────────────────────────────────────────────────

  static TokenRefreshService get instance => Get.find<TokenRefreshService>();

  /// Registers and starts the service. Safe to call multiple times.
  static Future<TokenRefreshService> start() async {
    if (!Get.isRegistered<TokenRefreshService>()) {
      Get.put<TokenRefreshService>(TokenRefreshService(), permanent: true);
    }
    await instance._begin();
    return instance;
  }

  /// Stops the timer and unregisters the service.
  static void stop() {
    if (Get.isRegistered<TokenRefreshService>()) {
      instance._cancel();
      Get.delete<TokenRefreshService>(force: true);
    }
  }

  // ── internal ──────────────────────────────────────────────────────────────

  Future<void> _begin() async {
    _cancel();
    _running = true;

    final refreshToken = await _store.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return;

    // Calculate when to fire the first refresh.
    final remaining = await _store.remainingTokenLife();
    final firstFireIn = remaining > _earlyBuffer
        ? remaining - _earlyBuffer
        : Duration.zero; // already expired or near-expiry → refresh now

    if (firstFireIn == Duration.zero) {
      await _tryRefresh();
    } else {
      _timer = Timer(firstFireIn, _onTimerFired);
    }
  }

  void _onTimerFired() {
    if (!_running) return;
    _tryRefresh().then((_) {
      if (_running) {
        _timer = Timer(_refreshInterval, _onTimerFired);
      }
    });
  }

  Future<void> _tryRefresh() async {
    if (!_running) return;

    final refreshToken = await _store.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _cancel();
      return;
    }

    final online = await _isOnline();
    if (!online) {
      // Offline — schedule a short retry without touching the stored token.
      _timer = Timer(_retryInterval, _onTimerFired);
      return;
    }

    final newAccessToken = await _client.refresh(refreshToken);
    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      // Keep the same refresh token; only the access token changes.
      await _store.saveTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );
    }
    // On network failure the stored token is untouched; the 401-retry in
    // AuthService/_ProfileService will handle it for individual requests.
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _cancel() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _cancel();
    super.onClose();
  }
}

/// Minimal HTTP client for the refresh endpoint only.
/// Kept separate to avoid a circular dependency with AuthService.
class _RefreshClient {
  _RefreshClient(String baseUrl)
      : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;

  final String _baseUrl;
  final GetConnect _http = GetConnect(timeout: const Duration(seconds: 15));

  Future<String?> refresh(String refreshToken) async {
    try {
      final response = await _http.post(
        '$_baseUrl/auth/refresh-token',
        RefreshTokenRequest(refreshToken: refreshToken).toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      final body = response.body;
      if (body is Map) {
        return (body['accessToken'] ??
                body['access_token'] ??
                body['data']?['accessToken'] ??
                body['data']?['access_token'])
            ?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
