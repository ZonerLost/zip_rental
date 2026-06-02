import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/config/api/api_config.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';

class ItemApiService {
  ItemApiService({AuthService? authService})
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

  Future<PaginatedItemsResponse> browseItems({
    int page = 1,
    int limit = 10,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? search,
    String? sortBy,
    String? sortOrder,
    double? distance,
  }) async {
    final response = await _request(
      method: _HttpMethod.get,
      path: '/items',
      requiresAuth: false,
      query: <String, dynamic>{
        'page': page.toString(),
        'limit': limit.clamp(1, 50).toString(),
        if ((category ?? '').trim().isNotEmpty) 'category': category!.trim(),
        if ((city ?? '').trim().isNotEmpty) 'city': city!.trim(),
        if (minPrice != null) 'minPrice': minPrice.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
        if ((condition ?? '').trim().isNotEmpty) 'condition': condition!.trim(),
        if ((search ?? '').trim().isNotEmpty) 'search': search!.trim(),
        if ((sortBy ?? '').trim().isNotEmpty) 'sortBy': sortBy!.trim(),
        if ((sortOrder ?? '').trim().isNotEmpty) 'sortOrder': sortOrder!.trim(),
        if (distance != null) 'distance': distance.toString(),
      },
    );

    final success = _resolveSuccess(response);
    final map = _asMap(response.body);
    final message = _resolveMessage(response, success);
    final items = _parseItems(map);
    final pagination = _parsePagination(map);

    return PaginatedItemsResponse(
      success: success,
      message: message,
      items: items,
      pagination: pagination,
      raw: map,
    );
  }

  Future<ItemModel> getItemById(String id) async {
    final response = await _request(
      method: _HttpMethod.get,
      path: '/items/${Uri.encodeComponent(id)}',
      requiresAuth: false,
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<ItemModel> createItem(CreateItemRequest request) async {
    final response = await _request(
      method: _HttpMethod.post,
      path: '/items',
      requiresAuth: true,
      body: request.toJson(),
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<List<ItemModel>> getMyListings() async {
    final response = await _request(
      method: _HttpMethod.get,
      path: '/items/my-listings',
      requiresAuth: true,
    );

    final success = _resolveSuccess(response);
    final message = _resolveMessage(response, success);
    if (!success) {
      throw Exception(message);
    }

    return _parseItems(_asMap(response.body));
  }

  Future<ItemModel> updateItem(String id, UpdateItemRequest request) async {
    final response = await _request(
      method: _HttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}',
      requiresAuth: true,
      body: request.toJson(),
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<bool> deleteItem(String id) async {
    final response = await _request(
      method: _HttpMethod.delete,
      path: '/items/${Uri.encodeComponent(id)}',
      requiresAuth: true,
    );

    final success = _resolveSuccess(response);
    if (!success) {
      throw Exception(_resolveMessage(response, false));
    }
    return true;
  }

  Future<ItemModel> pauseListing(String id) async {
    final response = await _request(
      method: _HttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/pause',
      requiresAuth: true,
    );

    final success = _resolveSuccess(response);
    if (!success) {
      throw Exception(_resolveMessage(response, false));
    }
    // Patch the isPaused flag from the response data
    final map = _asMap(response.body);
    final dataRaw = _getByPath(map, 'data');
    final dataMap = dataRaw is Map ? _stringKeyMap(dataRaw) : <String, dynamic>{};
    final isPaused = dataMap['isPaused'] as bool? ?? true;
    return _parsePausedItem(response, isPaused: isPaused);
  }

  Future<ItemModel> resumeListing(String id) async {
    final response = await _request(
      method: _HttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/resume',
      requiresAuth: true,
    );

    final success = _resolveSuccess(response);
    if (!success) {
      throw Exception(_resolveMessage(response, false));
    }
    final map = _asMap(response.body);
    final dataRaw = _getByPath(map, 'data');
    final dataMap = dataRaw is Map ? _stringKeyMap(dataRaw) : <String, dynamic>{};
    final isPaused = dataMap['isPaused'] as bool? ?? false;
    return _parsePausedItem(response, isPaused: isPaused);
  }

  /// The pause/resume endpoints only return `{ _id, isPaused }` inside `data`.
  /// We use the id to look up the full item and just patch the isPaused flag.
  ItemModel _parsePausedItem(Response<dynamic> response, {required bool isPaused}) {
    final map = _asMap(response.body);
    final dataRaw = _getByPath(map, 'data');
    final dataMap = dataRaw is Map ? _stringKeyMap(dataRaw) : <String, dynamic>{};
    final id = dataMap['_id']?.toString().trim().isNotEmpty == true
        ? dataMap['_id'].toString().trim()
        : dataMap['id']?.toString().trim() ?? '';
    return ItemModel(id: id, isPaused: isPaused);
  }

  Future<List<String>> uploadItemPhotos(String id, List<File> photos) async {
    final files = photos
        .map(
          (file) => MultipartFile(
            file,
            filename: _extractFileName(file.path),
            contentType: _mimeTypeFromPath(file.path),
          ),
        )
        .toList(growable: false);

    final formData = FormData(<String, dynamic>{'photos': files});

    final response = await _request(
      method: _HttpMethod.post,
      path: '/items/${Uri.encodeComponent(id)}/photos',
      requiresAuth: true,
      body: formData,
    );

    final success = _resolveSuccess(response);
    final message = _resolveMessage(response, success);
    final map = _asMap(response.body);

    if (!success) {
      throw Exception(message);
    }

    final photosList = _toStringList(_getByPath(map, 'data.photos'));
    return photosList;
  }

  Future<bool> deleteItemPhoto(String id, String photoUrl) async {
    final response = await _request(
      method: _HttpMethod.deleteWithBody,
      path: '/items/${Uri.encodeComponent(id)}/photos',
      requiresAuth: true,
      body: <String, dynamic>{'photoUrl': photoUrl},
    );

    final success = _resolveSuccess(response);
    if (!success) {
      throw Exception(_resolveMessage(response, false));
    }
    return true;
  }

  Future<ItemModel> updateAvailability(
    String id, {
    bool? isAvailable,
    List<String>? blockedDates,
  }) async {
    final payload = <String, dynamic>{
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (blockedDates != null) 'blockedDates': blockedDates,
    };

    final response = await _request(
      method: _HttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/availability',
      requiresAuth: true,
      body: payload,
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<Response<dynamic>> _request({
    required _HttpMethod method,
    required String path,
    required bool requiresAuth,
    dynamic body,
    Map<String, dynamic>? query,
    bool isRetry = false,
  }) async {
    if (!_hasValidBaseUrl) {
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
      accessToken = await _authService.ensureAccessToken();
    }

    final response = await _dispatch(
      method: method,
      path: path,
      body: body,
      query: query,
      accessToken: accessToken,
    );

    if (response.statusCode == 401 && requiresAuth && !isRetry) {
      final refreshResult = await _authService.refreshToken();
      if (refreshResult.success) {
        return _request(
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

  Future<Response<dynamic>> _dispatch({
    required _HttpMethod method,
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
      case _HttpMethod.get:
        return _client.get(path, headers: headers, query: query);
      case _HttpMethod.post:
        return _client.post(path, body, headers: headers, query: query);
      case _HttpMethod.put:
        return _client.put(path, body, headers: headers, query: query);
      case _HttpMethod.delete:
        return _client.delete(path, headers: headers, query: query);
      case _HttpMethod.deleteWithBody:
        return _client.request<dynamic>(
          path,
          'delete',
          body: body,
          headers: headers,
          query: query,
        );
    }
  }

  _SingleItemResult _parseSingleItemResponse(Response<dynamic> response) {
    final success = _resolveSuccess(response);
    final message = _resolveMessage(response, success);
    final map = _asMap(response.body);

    if (!success) {
      return _SingleItemResult(success: false, message: message, item: null);
    }

    final candidates = <dynamic>[
      _getByPath(map, 'data'),
      _getByPath(map, 'item'),
      map,
    ];

    ItemModel? item;
    for (final candidate in candidates) {
      if (candidate is Map) {
        final candidateMap = _stringKeyMap(candidate);
        if (_looksLikeItem(candidateMap)) {
          final parsed = ItemModel.fromJson(candidateMap);
          if (parsed.id.trim().isNotEmpty) {
            item = parsed;
            break;
          }
        }
      }
    }

    return _SingleItemResult(success: true, message: message, item: item);
  }

  List<ItemModel> _parseItems(Map<String, dynamic> root) {
    final candidates = <dynamic>[
      _getByPath(root, 'data'),
      _getByPath(root, 'items'),
      _getByPath(root, 'results'),
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((e) => ItemModel.fromJson(_stringKeyMap(e)))
            .where((item) => item.id.trim().isNotEmpty)
            .toList(growable: false);
      }
    }

    return const <ItemModel>[];
  }

  PaginationModel? _parsePagination(Map<String, dynamic> root) {
    final raw = _getByPath(root, 'pagination');
    if (raw is! Map) {
      return null;
    }
    return PaginationModel.fromJson(_stringKeyMap(raw));
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
      final enriched = _extractDetailedValidationMessage(map);
      if (enriched != null) {
        return '$message: $enriched';
      }
      return message;
    }
    final errors = map['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is String && firstError.trim().isNotEmpty) {
        return firstError;
      }
      if (firstError is Map) {
        final details = _readErrorMap(firstError);
        if (details != null) {
          return details;
        }
      }
    }
    final statusText = response.statusText;
    if (!success && statusText != null && statusText.trim().isNotEmpty) {
      return statusText;
    }
    return success ? 'Request successful' : 'Request failed';
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) {
      return _stringKeyMap(raw);
    }
    return <String, dynamic>{'raw': raw};
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

  bool _looksLikeItem(Map<String, dynamic> map) {
    return map.containsKey('_id') ||
        map.containsKey('id') ||
        map.containsKey('title') ||
        map.containsKey('dailyRate') ||
        map.containsKey('category');
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

  List<String> _toStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((element) => element?.toString().trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  String? _extractDetailedValidationMessage(Map<String, dynamic> map) {
    final errors = map['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is String && firstError.trim().isNotEmpty) {
        return firstError.trim();
      }
      if (firstError is Map) {
        return _readErrorMap(firstError);
      }
    }

    final error = map['error'];
    if (error is Map) {
      return _readErrorMap(error);
    }
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }
    return null;
  }

  String? _readErrorMap(Map<dynamic, dynamic> raw) {
    final map = _stringKeyMap(raw);
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

class _SingleItemResult {
  const _SingleItemResult({
    required this.success,
    required this.message,
    required this.item,
  });

  final bool success;
  final String message;
  final ItemModel? item;
}

enum _HttpMethod { get, post, put, delete, deleteWithBody }
