import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/config/api/api_config.dart';
import 'package:zip_peer/services/auth/auth_service.dart';

enum ApiHttpMethod { get, post, put, delete, deleteWithBody }

abstract class ApiServiceBase {
  ApiServiceBase({AuthService? authService})
    : authService = authService ?? AuthService() {
    final configuredBaseUrl = ApiConfig.baseUrl.trim();
    client = GetConnect(
      timeout: const Duration(seconds: 25),
      userAgent: 'zip-peer-app',
    );
    client.baseUrl = configuredBaseUrl.endsWith('/')
        ? configuredBaseUrl.substring(0, configuredBaseUrl.length - 1)
        : configuredBaseUrl;
  }

  final AuthService authService;
  late final GetConnect client;

  bool get hasValidBaseUrl {
    final baseUrl = client.baseUrl ?? '';
    if (baseUrl.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(baseUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Future<Response<dynamic>> request({
    required ApiHttpMethod method,
    required String path,
    required bool requiresAuth,
    dynamic body,
    Map<String, dynamic>? query,
    bool isRetry = false,
  }) async {
    if (!hasValidBaseUrl) {
      return Response<dynamic>(
        statusCode: 0,
        body: <String, dynamic>{
          'success': false,
          'message': 'API base URL missing or invalid.',
        },
      );
    }

    String? accessToken;
    if (requiresAuth) {
      accessToken = await authService.ensureAccessToken();
    }

    final response = await dispatch(
      method: method,
      path: path,
      body: body,
      query: query,
      accessToken: accessToken,
    );

    if (response.statusCode == 401 && requiresAuth && !isRetry) {
      final refreshResult = await authService.refreshToken();
      if (refreshResult.success) {
        return request(
          method: method,
          path: path,
          requiresAuth: true,
          body: body,
          query: query,
          isRetry: true,
        );
      }
    }

    return response;
  }

  Future<Response<dynamic>> dispatch({
    required ApiHttpMethod method,
    required String path,
    dynamic body,
    Map<String, dynamic>? query,
    String? accessToken,
  }) {
    final isMultipart = body is FormData;
    final headers = <String, String>{
      'Accept': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      if (body != null && !isMultipart) 'Content-Type': 'application/json',
    };

    switch (method) {
      case ApiHttpMethod.get:
        return client.get(path, headers: headers, query: query);
      case ApiHttpMethod.post:
        return client.post(path, body, headers: headers, query: query);
      case ApiHttpMethod.put:
        return client.put(path, body, headers: headers, query: query);
      case ApiHttpMethod.delete:
        return client.delete(path, headers: headers, query: query);
      case ApiHttpMethod.deleteWithBody:
        return client.request<dynamic>(
          path,
          'delete',
          body: body,
          headers: headers,
          query: query,
        );
    }
  }

  bool resolveSuccess(Response<dynamic> response) {
    final map = asMap(response.body);
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

  String resolveMessage(
    Response<dynamic> response,
    bool success, {
    String? notFoundMessage,
    String? forbiddenMessage,
  }) {
    final map = asMap(response.body);
    final dynamic message = map['message'] ?? map['msg'] ?? map['detail'];
    final detailedMessage = extractDetailedValidationMessage(map);
    final statusCode = response.statusCode ?? 0;

    if (statusCode == 0) {
      return 'Unable to reach the server. Please check your internet connection.';
    }
    if (statusCode == 401) {
      return (message is String && message.trim().isNotEmpty)
          ? message
          : 'Your session has expired. Please sign in again.';
    }
    if (statusCode == 403) {
      return forbiddenMessage ??
          ((message is String && message.trim().isNotEmpty)
              ? message
              : 'You do not have permission to perform this action.');
    }
    if (statusCode == 404) {
      return notFoundMessage ??
          ((message is String && message.trim().isNotEmpty)
              ? message
              : 'Requested resource not found.');
    }

    if (message is String && message.trim().isNotEmpty) {
      if (detailedMessage != null &&
          detailedMessage.isNotEmpty &&
          detailedMessage != message.trim()) {
        return '$message: $detailedMessage';
      }
      return message;
    }

    if (detailedMessage != null && detailedMessage.isNotEmpty) {
      return detailedMessage;
    }

    final statusText = response.statusText;
    if (!success && statusText != null && statusText.trim().isNotEmpty) {
      return statusText;
    }
    return success ? 'Request successful' : 'Request failed';
  }

  Map<String, dynamic> asMap(dynamic raw) {
    if (raw is Map) {
      return stringKeyMap(raw);
    }
    return <String, dynamic>{'raw': raw};
  }

  dynamic getByPath(Map<String, dynamic> root, String path) {
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

  Map<String, dynamic> stringKeyMap(Map<dynamic, dynamic> source) {
    return source.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), stringKeyMap(value));
      }
      if (value is List) {
        return MapEntry(key.toString(), normalizeList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  List<dynamic> normalizeList(List<dynamic> values) {
    return values
        .map((value) {
          if (value is Map) {
            return stringKeyMap(value);
          }
          if (value is List) {
            return normalizeList(value);
          }
          return value;
        })
        .toList(growable: false);
  }

  List<String> toStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((element) => element?.toString().trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  String extractFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/');
    return segments.isNotEmpty && segments.last.trim().isNotEmpty
        ? segments.last
        : 'upload_file';
  }

  String mimeTypeFromPath(String path) {
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

  MultipartFile multipartFileFromPath(File file) {
    return MultipartFile(
      file,
      filename: extractFileName(file.path),
      contentType: mimeTypeFromPath(file.path),
    );
  }

  String? extractDetailedValidationMessage(Map<String, dynamic> map) {
    final errors = map['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is String && firstError.trim().isNotEmpty) {
        return firstError.trim();
      }
      if (firstError is Map) {
        return readErrorMap(firstError);
      }
    }

    final error = map['error'];
    if (error is Map) {
      return readErrorMap(error);
    }
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }
    return null;
  }

  String? readErrorMap(Map<dynamic, dynamic> raw) {
    final map = stringKeyMap(raw);
    final field =
        map['field']?.toString().trim() ??
        map['path']?.toString().trim() ??
        map['property']?.toString().trim();

    final msg =
        map['message']?.toString().trim() ??
        map['msg']?.toString().trim() ??
        map['detail']?.toString().trim();

    if ((field ?? '').isNotEmpty && (msg ?? '').isNotEmpty) {
      return '$field: $msg';
    }
    if ((msg ?? '').isNotEmpty) {
      return msg;
    }

    final constraints = map['constraints'];
    if (constraints is Map) {
      final values = constraints.values
          .map((e) => e?.toString().trim())
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      if (values.isNotEmpty) {
        final text = values.join(', ');
        if ((field ?? '').isNotEmpty) {
          return '$field: $text';
        }
        return text;
      }
    }

    return null;
  }
}
