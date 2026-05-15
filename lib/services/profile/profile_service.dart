import 'dart:io';

import 'package:get/get.dart';
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
    return _uploadFile(
      method: _HttpMethod.put,
      path: '/users/profile/photo',
      fieldName: 'photo',
      file: file,
    );
  }

  Future<ProfileResult> verifyIdentity(File file) {
    return _uploadFile(
      method: _HttpMethod.post,
      path: '/users/identity-verify',
      fieldName: 'document',
      file: file,
    );
  }

  Future<ProfileResult> _uploadFile({
    required _HttpMethod method,
    required String path,
    required String fieldName,
    required File file,
  }) async {
    final fileName = _extractFileName(file.path);
    final mimeType = _mimeTypeFromPath(file.path);
    final formData = FormData(<String, dynamic>{
      fieldName: MultipartFile(file, filename: fileName, contentType: mimeType),
    });

    return _request(method: method, path: path, body: formData);
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
    final map = raw is Map<String, dynamic>
        ? raw
        : <String, dynamic>{'raw': raw};
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
    final directUser = root['user'];
    if (directUser is Map<String, dynamic>) {
      return UserProfile.fromJson(directUser);
    }
    final data = root['data'];
    if (data is Map<String, dynamic>) {
      if (data['user'] is Map<String, dynamic>) {
        return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
      }
      return UserProfile.fromJson(data);
    }

    final hasKnownFields =
        root.containsKey('firstName') ||
        root.containsKey('lastName') ||
        root.containsKey('email') ||
        root.containsKey('phone');
    if (hasKnownFields) {
      return UserProfile.fromJson(root);
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
    final direct = root['profilePhoto']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    final data = root['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['profilePhoto']?.toString();
      if (nested != null && nested.isNotEmpty) {
        return nested;
      }
    }
    return profile?.profilePhoto;
  }

  String _extractFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/');
    return segments.isNotEmpty && segments.last.trim().isNotEmpty
        ? segments.last
        : 'upload_file';
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'application/octet-stream';
  }
}

enum _HttpMethod { get, post, put }
