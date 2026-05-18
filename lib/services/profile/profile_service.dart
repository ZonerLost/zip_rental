import 'dart:io';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zip_peer/config/api/api_config.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';

class ProfileService {
  ProfileService({AuthService? authService})
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

  Future<ProfileResult> getProfile() async {
    return _request(method: _HttpMethod.get, path: '/users/profile');
  }

  Future<ProfileResult> updateProfile(UpdateProfileRequest request) async {
    return _request(
      method: _HttpMethod.put,
      path: '/users/profile',
      body: request.toJson(),
    );
  }

  Future<ProfileResult> uploadProfilePhoto(File file) {
    return _multipartRequest(
      method: 'PUT',
      path: '/users/profile/photo',
      fieldName: 'photo',
      file: file,
    );
  }

  Future<ProfileResult> verifyIdentity(File file) {
    return _multipartRequest(
      method: 'POST',
      path: '/users/identity-verify',
      fieldName: 'document',
      file: file,
    );
  }

  Future<ProfileResult> _multipartRequest({
    required String method,
    required String path,
    required String fieldName,
    required File file,
  }) async {
    if (!_hasValidBaseUrl) {
      return const ProfileResult(
        success: false,
        message: 'API base URL missing or invalid.',
      );
    }
    final accessToken = await _authService.ensureAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return const ProfileResult(
        success: false,
        message: 'You are not authenticated. Please log in again.',
      );
    }

    Future<ProfileResult> doRequest(String token) async {
      final uri = Uri.parse('${_client.baseUrl}$path');
      final request = http.MultipartRequest(method, uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: _mediaTypeFromPath(file.path),
        ));
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final decoded = jsonDecode(body);
      final map = decoded is Map ? _stringKeyMap(decoded) : <String, dynamic>{};
      final profile = _resolveProfile(map);
      final success = map['success'] == true ||
          (streamed.statusCode >= 200 && streamed.statusCode < 300 && map['success'] != false);
      final message = map['message']?.toString() ??
          (success ? 'Request successful' : 'Request failed');
      return ProfileResult(
        success: success,
        message: message,
        data: map,
        profile: profile,
        profilePhoto: _resolveProfilePhoto(map, profile),
      );
    }

    var result = await doRequest(accessToken);
    // retry once on 401
    if (!result.success && (result.data?['statusCode'] == 401 || result.data?['status'] == 401)) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.success) {
        final newToken = await _authService.getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          result = await doRequest(newToken);
        }
      }
    }
    return result;
  }

  http.MediaType _mediaTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return http.MediaType('image', 'jpeg');
    }
    if (lower.endsWith('.png')) return http.MediaType('image', 'png');
    if (lower.endsWith('.webp')) return http.MediaType('image', 'webp');
    return http.MediaType('application', 'octet-stream');
  }

  Future<ProfileResult> _request({
    required _HttpMethod method,
    required String path,
    dynamic body,
  }) async {
    if (!_hasValidBaseUrl) {
      return const ProfileResult(
        success: false,
        message:
            'API base URL missing or invalid. Run with --dart-define=API_BASE_URL=https://your-domain.com',
      );
    }

    final accessToken = await _authService.ensureAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return const ProfileResult(
        success: false,
        message: 'You are not authenticated. Please log in again.',
      );
    }

    Response<dynamic> response = await _dispatch(
      method: method,
      path: path,
      body: body,
      accessToken: accessToken,
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
            body: body,
            accessToken: retriedAccessToken,
          );
        }
      }
    }

    return _toProfileResult(response);
  }

  Future<Response<dynamic>> _dispatch({
    required _HttpMethod method,
    required String path,
    required dynamic body,
    required String accessToken,
  }) {
    final isMultipart = body is FormData;
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      if (!isMultipart) 'Content-Type': 'application/json',
    };

    switch (method) {
      case _HttpMethod.get:
        return _client.get(path, headers: headers);
      case _HttpMethod.post:
        return _client.post(path, body, headers: headers);
      case _HttpMethod.put:
        return _client.put(path, body, headers: headers);
    }
  }

  ProfileResult _toProfileResult(Response<dynamic> response) {
    final raw = response.body;
    final map = raw is Map ? _stringKeyMap(raw) : <String, dynamic>{'raw': raw};
    final profile = _resolveProfile(map);
    final success = _resolveSuccess(response, map);
    final message = _resolveMessage(map, success, response.statusText);
    final profilePhoto = _resolveProfilePhoto(map, profile);

    return ProfileResult(
      success: success,
      message: message,
      data: map,
      profile: profile,
      profilePhoto: profilePhoto,
    );
  }

  UserProfile? _resolveProfile(Map<String, dynamic> root) {
    final candidates = <Map<String, dynamic>>[
      ..._collectMapsAtPaths(root, const [
        'user',
        'profile',
        'data.user',
        'data.profile',
        'data',
      ]),
      root,
    ];

    for (final candidate in candidates) {
      if (_looksLikeProfile(candidate)) {
        return UserProfile.fromJson(candidate);
      }
    }
    return null;
  }

  bool _resolveSuccess(Response<dynamic> response, Map<String, dynamic> data) {
    if (data['success'] is bool) {
      return data['success'] as bool;
    }
    if (response.statusCode != null &&
        (response.statusCode! < 200 || response.statusCode! > 299)) {
      return false;
    }
    if (data['error'] != null) {
      return false;
    }
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      return false;
    }
    final status = data['status'];
    if (status is String && status.toLowerCase() == 'error') {
      return false;
    }
    return response.isOk;
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

  String? _resolveProfilePhoto(
    Map<String, dynamic> root,
    UserProfile? profile,
  ) {
    final extracted = _extractPhotoFromMap(root);
    if (extracted != null) {
      return extracted;
    }
    return _normalizePhotoUrl(profile?.profilePhoto);
  }

bool _looksLikeProfile(Map<String, dynamic> data) {
    return data.containsKey('firstName') ||
        data.containsKey('first_name') ||
        data.containsKey('lastName') ||
        data.containsKey('last_name') ||
        data.containsKey('email') ||
        data.containsKey('phone') ||
        data.containsKey('profilePhoto') ||
        data.containsKey('profile_photo') ||
        data.containsKey('avatar');
  }

  List<Map<String, dynamic>> _collectMapsAtPaths(
    Map<String, dynamic> root,
    List<String> paths,
  ) {
    final results = <Map<String, dynamic>>[];
    for (final path in paths) {
      final value = _getByPath(root, path);
      if (value is Map) {
        results.add(_stringKeyMap(value));
      }
    }
    return results;
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

  String? _extractPhotoFromMap(Map<String, dynamic> root) {
    final pathCandidates = <String>[
      'profilePhoto',
      'profile_photo',
      'avatar',
      'avatarUrl',
      'avatar_url',
      'photo',
      'image',
      'user.profilePhoto',
      'user.profile_photo',
      'user.avatar',
      'profile.profilePhoto',
      'profile.profile_photo',
      'profile.avatar',
      'data.profilePhoto',
      'data.profile_photo',
      'data.avatar',
      'data.user.profilePhoto',
      'data.user.profile_photo',
      'data.user.avatar',
      'data.profile.profilePhoto',
      'data.profile.profile_photo',
      'data.profile.avatar',
    ];

    for (final path in pathCandidates) {
      final value = _getByPath(root, path);
      final normalized = _normalizePhotoUrl(value?.toString());
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }

  String? _normalizePhotoUrl(String? raw) {
    if (raw == null) {
      return null;
    }
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }

    final base = _client.baseUrl ?? '';
    final baseUri = Uri.tryParse(base);
    if (baseUri == null || baseUri.host.isEmpty || baseUri.scheme.isEmpty) {
      return value;
    }

    final origin =
        '${baseUri.scheme}://${baseUri.host}'
        '${baseUri.hasPort ? ':${baseUri.port}' : ''}';
    if (value.startsWith('/')) {
      return '$origin$value';
    }
    return '$origin/$value';
  }

  Map<String, dynamic> _stringKeyMap(Map<dynamic, dynamic> source) {
    return source.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _stringKeyMap(value));
      }
      if (value is List) {
        return MapEntry(key.toString(), _normalizeList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  List<dynamic> _normalizeList(List<dynamic> values) {
    return values
        .map((value) {
          if (value is Map) {
            return _stringKeyMap(value);
          }
          if (value is List) {
            return _normalizeList(value);
          }
          return value;
        })
        .toList(growable: false);
  }
}

enum _HttpMethod { get, post, put }
