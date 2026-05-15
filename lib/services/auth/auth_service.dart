import 'package:get/get.dart';
import 'package:zip_peer/config/api/api_config.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_session_store.dart';

class AuthService {
  AuthService({AuthSessionStore? sessionStore})
    : _sessionStore = sessionStore ?? AuthSessionStore() {
    final configuredBaseUrl = ApiConfig.baseUrl.trim();
    _client = GetConnect(
      timeout: const Duration(seconds: 25),
      userAgent: 'zip-peer-app',
    );
    _client.baseUrl = configuredBaseUrl.endsWith('/')
        ? configuredBaseUrl.substring(0, configuredBaseUrl.length - 1)
        : configuredBaseUrl;
  }

  late final GetConnect _client;
  final AuthSessionStore _sessionStore;

  bool get _hasValidBaseUrl {
    final baseUrl = _client.baseUrl ?? '';
    if (baseUrl.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(baseUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Future<AuthResult> register(RegisterRequest request) {
    return _post('/auth/register', request.toJson()).then((result) async {
      if (result.success) {
        await _sessionStore.savePendingEmail(request.email);
      }
      return result;
    });
  }

  Future<AuthResult> verifyEmail(VerifyEmailRequest request) {
    return _post('/auth/verify-email', request.toJson());
  }

  Future<AuthResult> resendVerification(ResendVerificationRequest request) {
    return _post('/auth/resend-verification', request.toJson());
  }

  Future<AuthResult> login(LoginRequest request) async {
    final result = await _post('/auth/login', request.toJson());
    final tokens = result.tokens;
    final hasValidTokenPair =
        tokens != null &&
        tokens.accessToken.isNotEmpty &&
        tokens.refreshToken.isNotEmpty;

    if (!result.success || !hasValidTokenPair) {
      return AuthResult(
        success: false,
        message: hasValidTokenPair
            ? result.message
            : (result.message == 'Request successful'
                  ? 'Invalid email or password'
                  : result.message),
        tokens: result.tokens,
        data: result.data,
      );
    }

    if (result.success) {
      await _sessionStore.saveTokens(
        accessToken: result.tokens!.accessToken,
        refreshToken: result.tokens!.refreshToken,
      );
      await _sessionStore.clearPendingEmail();
    }
    return result;
  }

  Future<AuthResult> googleAuth(GoogleAuthRequest request) async {
    final result = await _post('/auth/google', request.toJson());
    if (result.success &&
        result.tokens != null &&
        result.tokens!.accessToken.isNotEmpty) {
      final existingRefresh = await _sessionStore.getRefreshToken();
      await _sessionStore.saveTokens(
        accessToken: result.tokens!.accessToken,
        refreshToken: result.tokens!.refreshToken.isNotEmpty
            ? result.tokens!.refreshToken
            : (existingRefresh ?? ''),
      );
    }
    return result;
  }

  Future<AuthResult> forgotPassword(ForgotPasswordRequest request) {
    return _post('/auth/forgot-password', request.toJson()).then((
      result,
    ) async {
      if (result.success) {
        await _sessionStore.savePendingEmail(request.email);
      }
      return result;
    });
  }

  Future<AuthResult> resetPassword(ResetPasswordRequest request) async {
    final result = await _post('/auth/reset-password', request.toJson());
    if (result.success) {
      await _sessionStore.clearPendingEmail();
    }
    return result;
  }

  Future<AuthResult> refreshToken([String? refreshToken]) async {
    final token = refreshToken ?? await _sessionStore.getRefreshToken();
    if (token == null || token.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Refresh token not found',
      );
    }
    final result = await _post(
      '/auth/refresh-token',
      RefreshTokenRequest(refreshToken: token).toJson(),
    );
    if (result.success &&
        result.tokens != null &&
        result.tokens!.accessToken.isNotEmpty) {
      await _sessionStore.saveTokens(
        accessToken: result.tokens!.accessToken,
        refreshToken: result.tokens!.refreshToken.isNotEmpty
            ? result.tokens!.refreshToken
            : token,
      );
    } else if (result.success && result.tokens == null) {
      return AuthResult(
        success: false,
        message: 'Refresh token response missing accessToken',
        tokens: result.tokens,
        data: result.data,
      );
    }
    return result;
  }

  Future<String?> ensureAccessToken() async {
    final existingAccessToken = await _sessionStore.getAccessToken();
    if (existingAccessToken != null && existingAccessToken.isNotEmpty) {
      return existingAccessToken;
    }

    final refreshResult = await refreshToken();
    if (!refreshResult.success) {
      return null;
    }
    return _sessionStore.getAccessToken();
  }

  Future<Map<String, String>> getAuthorizedHeaders({
    bool autoRefreshIfMissing = true,
  }) async {
    var accessToken = await _sessionStore.getAccessToken();

    if (autoRefreshIfMissing && (accessToken == null || accessToken.isEmpty)) {
      accessToken = await ensureAccessToken();
    }

    return <String, String>{
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Future<AuthResult> logout() async {
    final refreshToken = await _sessionStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return const AuthResult(success: false, message: 'No active session');
    }

    var accessToken = await ensureAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Unable to get valid access token for logout',
      );
    }

    var result = await _post(
      '/auth/logout',
      LogoutRequest(refreshToken: refreshToken).toJson(),
      authToken: accessToken,
    );

    if (!result.success) {
      final refreshResult = await this.refreshToken(refreshToken);
      if (refreshResult.success) {
        final retriedAccessToken = await _sessionStore.getAccessToken();
        result = await _post(
          '/auth/logout',
          LogoutRequest(refreshToken: refreshToken).toJson(),
          authToken: retriedAccessToken,
        );
      }
    }

    if (result.success) {
      await _sessionStore.clearTokens();
    }
    return result;
  }

  Future<String?> getPendingEmail() => _sessionStore.getPendingEmail();

  Future<void> savePendingEmail(String email) =>
      _sessionStore.savePendingEmail(email);

  Future<String?> getAccessToken() => _sessionStore.getAccessToken();

  Future<String?> getRefreshToken() => _sessionStore.getRefreshToken();

  Future<AuthResult> _post(
    String path,
    Map<String, dynamic> payload, {
    String? authToken,
  }) async {
    if (!_hasValidBaseUrl) {
      return const AuthResult(
        success: false,
        message:
            'API base URL missing or invalid. Run with --dart-define=API_BASE_URL=https://your-domain.com',
      );
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    var response = await _client.post(path, payload, headers: headers);

    final shouldRetryWithRefresh =
        authToken != null &&
        authToken.isNotEmpty &&
        response.statusCode == 401 &&
        path != '/auth/refresh-token';

    if (shouldRetryWithRefresh) {
      final refreshResult = await refreshToken();
      if (refreshResult.success) {
        final retriedAccessToken = await _sessionStore.getAccessToken();
        if (retriedAccessToken != null &&
            retriedAccessToken.isNotEmpty &&
            retriedAccessToken != authToken) {
          final retryHeaders = <String, String>{
            ...headers,
            'Authorization': 'Bearer $retriedAccessToken',
          };
          response = await _client.post(path, payload, headers: retryHeaders);
        }
      }
    }

    return _toAuthResult(response);
  }

  AuthResult _toAuthResult(Response<dynamic> response) {
    final data = response.body;
    final map = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{'raw': data};

    final tokens = _resolveTokens(map);
    final success = _resolveSuccess(response, map, tokens);
    final message = _resolveMessage(map, success, response.statusText);

    return AuthResult(
      success: success,
      message: message,
      tokens: tokens,
      data: map,
    );
  }

  bool _resolveSuccess(
    Response<dynamic> response,
    Map<String, dynamic> data,
    AuthTokens? tokens,
  ) {
    if (data['success'] is bool) {
      return data['success'] as bool;
    }
    if (response.statusCode != null &&
        (response.statusCode! < 200 || response.statusCode! > 299)) {
      return false;
    }
    if (_hasErrorPayload(data)) {
      return false;
    }
    if (tokens != null && tokens.accessToken.isNotEmpty) {
      return true;
    }
    return response.isOk;
  }

  bool _hasErrorPayload(Map<String, dynamic> data) {
    if (data['error'] != null) {
      return true;
    }
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      return true;
    }
    final status = data['status'];
    if (status is String && status.toLowerCase() == 'error') {
      return true;
    }
    return false;
  }

  String _resolveMessage(
    Map<String, dynamic> data,
    bool success,
    String? statusText,
  ) {
    final dynamic message = data['message'] ?? data['msg'] ?? data['detail'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is String && firstError.trim().isNotEmpty) {
        return firstError;
      }
    }
    if (!success && statusText != null && statusText.trim().isNotEmpty) {
      return statusText;
    }
    return success ? 'Request successful' : 'Request failed';
  }

  AuthTokens? _resolveTokens(Map<String, dynamic> data) {
    final accessToken =
        (data['accessToken'] ??
                data['access_token'] ??
                data['token'] ??
                _getNestedValue(data, ['data', 'accessToken']) ??
                _getNestedValue(data, ['data', 'access_token']))
            ?.toString();

    final refreshToken =
        (data['refreshToken'] ??
                data['refresh_token'] ??
                _getNestedValue(data, ['data', 'refreshToken']) ??
                _getNestedValue(data, ['data', 'refresh_token']))
            ?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );
  }

  dynamic _getNestedValue(Map<String, dynamic> root, List<String> path) {
    dynamic current = root;
    for (final key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }
}
