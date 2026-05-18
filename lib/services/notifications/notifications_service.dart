import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zip_peer/config/api/api_config.dart';
import 'package:zip_peer/models/notifications/notification_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';

class NotificationsService {
  NotificationsService({AuthService? authService})
    : _authService = authService ?? AuthService() {
    final configuredBaseUrl = ApiConfig.baseUrl.trim();
    _client = GetConnect(
      timeout: const Duration(seconds: 25),
      userAgent: 'zip-peer-app',
    );
    _client.baseUrl = configuredBaseUrl.endsWith('/')
        ? configuredBaseUrl.substring(0, configuredBaseUrl.length - 1)
        : configuredBaseUrl;
  }

  static const _cachedFcmTokenKey = 'cached_fcm_token';

  final AuthService _authService;
  late final GetConnect _client;

  bool get _hasValidBaseUrl {
    final baseUrl = _client.baseUrl ?? '';
    if (baseUrl.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(baseUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Future<NotificationsPageResult> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _request(
      method: _HttpMethod.get,
      path: '/notifications',
      query: <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final success = _resolveSuccess(response);
    final message = _resolveMessage(response, success);
    final map = _asMap(response.body);
    final pageData = success
        ? _toPageData(map, page: page, limit: limit)
        : null;

    return NotificationsPageResult(
      success: success,
      message: message,
      data: pageData,
      raw: map,
    );
  }

  Future<NotificationActionResult> markAllRead() async {
    final response = await _request(
      method: _HttpMethod.put,
      path: '/notifications/read-all',
    );
    return _toActionResult(response);
  }

  Future<NotificationActionResult> markOneRead(String notificationId) async {
    final encodedId = Uri.encodeComponent(notificationId);
    final response = await _request(
      method: _HttpMethod.put,
      path: '/notifications/$encodedId/read',
    );
    return _toActionResult(response);
  }

  Future<NotificationActionResult> deleteNotification(
    String notificationId,
  ) async {
    final encodedId = Uri.encodeComponent(notificationId);
    final response = await _request(
      method: _HttpMethod.delete,
      path: '/notifications/$encodedId',
    );
    return _toActionResult(response);
  }

  Future<NotificationActionResult> saveFcmToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return const NotificationActionResult(
        success: false,
        message: 'FCM token is required',
      );
    }

    await _cacheFcmToken(trimmed);
    final response = await _request(
      method: _HttpMethod.post,
      path: '/users/fcm-token',
      body: <String, dynamic>{'token': trimmed},
    );
    return _toActionResult(response);
  }

  Future<void> cacheFcmToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await _cacheFcmToken(trimmed);
  }

  Future<String?> getCachedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_cachedFcmTokenKey);
    if (token == null || token.trim().isEmpty) {
      return null;
    }
    return token.trim();
  }

  Future<NotificationActionResult> syncSavedFcmTokenOnLaunch() async {
    final token = await getCachedFcmToken();
    if (token == null) {
      return const NotificationActionResult(
        success: false,
        message: 'No cached FCM token found',
      );
    }
    return saveFcmToken(token);
  }

  Future<void> _cacheFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedFcmTokenKey, token);
  }

  Future<Response<dynamic>> _request({
    required _HttpMethod method,
    required String path,
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    if (!_hasValidBaseUrl) {
      return Response<dynamic>(
        statusCode: 0,
        body: <String, dynamic>{
          'success': false,
          'message':
              'API base URL missing or invalid. Run with --dart-define=API_BASE_URL=https://your-domain.com',
        },
      );
    }

    final accessToken = await _authService.ensureAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return Response<dynamic>(
        statusCode: 401,
        body: <String, dynamic>{
          'success': false,
          'message': 'You are not authenticated. Please log in again.',
        },
      );
    }

    var response = await _dispatch(
      method: method,
      path: path,
      accessToken: accessToken,
      body: body,
      query: query,
    );

    if (response.statusCode == 401) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.success) {
        final retriedAccessToken = await _authService.getAccessToken();
        if (retriedAccessToken != null &&
            retriedAccessToken.isNotEmpty &&
            retriedAccessToken != accessToken) {
          response = await _dispatch(
            method: method,
            path: path,
            accessToken: retriedAccessToken,
            body: body,
            query: query,
          );
        }
      }
    }

    return response;
  }

  Future<Response<dynamic>> _dispatch({
    required _HttpMethod method,
    required String path,
    required String accessToken,
    dynamic body,
    Map<String, dynamic>? query,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      if (body != null) 'Content-Type': 'application/json',
    };

    switch (method) {
      case _HttpMethod.get:
        return _client.get(path, headers: headers, query: query);
      case _HttpMethod.post:
        return _client.post(path, body, headers: headers, query: query);
      case _HttpMethod.put:
        return _client.put(path, body, headers: headers, query: query);
      case _HttpMethod.delete:
        return _client.delete(path, headers: headers, query: query);
    }
  }

  NotificationActionResult _toActionResult(Response<dynamic> response) {
    final success = _resolveSuccess(response);
    final message = _resolveMessage(response, success);
    return NotificationActionResult(
      success: success,
      message: message,
      raw: _asMap(response.body),
    );
  }

  bool _resolveSuccess(Response<dynamic> response) {
    final map = _asMap(response.body);
    if (map['success'] is bool) {
      return map['success'] as bool;
    }
    if (response.statusCode != null &&
        (response.statusCode! < 200 || response.statusCode! > 299)) {
      return false;
    }
    if (map['error'] != null) {
      return false;
    }
    final errors = map['errors'];
    if (errors is List && errors.isNotEmpty) {
      return false;
    }
    final status = map['status'];
    if (status is String && status.toLowerCase() == 'error') {
      return false;
    }
    return response.isOk;
  }

  String _resolveMessage(Response<dynamic> response, bool success) {
    final map = _asMap(response.body);
    final dynamic message = map['message'] ?? map['msg'] ?? map['detail'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    final errors = map['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is String && first.trim().isNotEmpty) {
        return first;
      }
    }
    final statusText = response.statusText;
    if (!success && statusText != null && statusText.trim().isNotEmpty) {
      return statusText;
    }
    return success ? 'Request successful' : 'Request failed';
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    return <String, dynamic>{'raw': raw};
  }

  NotificationsPageData _toPageData(
    Map<String, dynamic> root, {
    required int page,
    required int limit,
  }) {
    final list = _extractNotificationList(root);
    final items = list
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .where((item) => item.id.trim().isNotEmpty)
        .toList(growable: false);

    final unreadCount = _readInt(root, const [
      'unreadCount',
      'data.unreadCount',
      'meta.unreadCount',
      'pagination.unreadCount',
    ]);
    final currentPage = _readInt(root, const [
      'page',
      'data.page',
      'meta.page',
    ]);
    final currentLimit = _readInt(root, const [
      'limit',
      'data.limit',
      'meta.limit',
      'pagination.limit',
    ]);
    final total = _readInt(root, const [
      'total',
      'data.total',
      'meta.total',
      'pagination.total',
      'count',
      'data.count',
    ]);
    final totalPages = _readInt(root, const [
      'totalPages',
      'data.totalPages',
      'meta.totalPages',
      'pagination.totalPages',
      'pages',
      'data.pages',
    ]);

    return NotificationsPageData(
      items: items,
      unreadCount: unreadCount,
      page: currentPage > 0 ? currentPage : page,
      limit: currentLimit > 0 ? currentLimit : limit,
      total: total,
      totalPages: totalPages,
    );
  }

  List<dynamic> _extractNotificationList(Map<String, dynamic> root) {
    final candidates = <dynamic>[
      root['notifications'],
      root['items'],
      root['results'],
      root['data'],
      _getByPath(root, 'data.notifications'),
      _getByPath(root, 'data.items'),
      _getByPath(root, 'data.results'),
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }
    return const [];
  }

  int _readInt(Map<String, dynamic> root, List<String> paths) {
    for (final path in paths) {
      final value = _getByPath(root, path);
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  dynamic _getByPath(Map<String, dynamic> root, String path) {
    final parts = path.split('.');
    dynamic current = root;
    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}

enum _HttpMethod { get, post, put, delete }
