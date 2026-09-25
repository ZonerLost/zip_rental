import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
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
///
/// Every actual refresh goes through [AuthService.refreshToken], which
/// de-duplicates concurrent refresh attempts and clears the session on a
/// definitive rejection — so this timer can never race a reactive,
/// request-triggered refresh happening elsewhere in the app.
class TokenRefreshService extends GetxService {
  static const Duration _refreshInterval = Duration(minutes: 14);
  static const Duration _retryInterval = Duration(minutes: 2);
  // Refresh 1 min before expiry when scheduling from a known remaining life.
  static const Duration _earlyBuffer = Duration(minutes: 1);

  final AuthSessionStore _store;
  final AuthService _authService;

  Timer? _timer;
  bool _running = false;

  TokenRefreshService({AuthSessionStore? store, AuthService? authService})
      : _store = store ?? AuthSessionStore(),
        _authService = authService ?? AuthService();

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
      _timer = Timer(_retryInterval, _onTimerFired);
      return;
    }

    // On failure (network hiccup or definitive rejection) AuthService has
    // already handled the stored session appropriately — nothing to do here.
    await _authService.refreshToken(refreshToken);
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
