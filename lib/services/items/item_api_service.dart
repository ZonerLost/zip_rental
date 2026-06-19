import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class ItemApiService extends ApiServiceBase {
  ItemApiService({AuthService? authService}) : super(authService: authService);

  Future<FeedResponse> getFeed({
    double? lat,
    double? lng,
    double radius = 20,
    int limit = 10,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/items/feed',
      requiresAuth: false,
      query: <String, dynamic>{
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        'radius': radius.toString(),
        'limit': limit.clamp(1, 20).toString(),
      },
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      return FeedResponse(success: false, message: message);
    }

    final map = asMap(response.body);
    final data = getByPath(map, 'data');
    final dataMap = data is Map ? stringKeyMap(data) : <String, dynamic>{};

    return FeedResponse(
      success: true,
      message: message,
      nearMe: _parseItemList(dataMap['nearMe']),
      popular: _parseItemList(dataMap['popular']),
      recent: _parseItemList(dataMap['recent']),
    );
  }

  List<ItemModel> _parseItemList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ItemModel.fromJson(stringKeyMap(e)))
        .where((item) => item.id.trim().isNotEmpty)
        .toList(growable: false);
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
    final response = await request(
      method: ApiHttpMethod.get,
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

    final success = resolveSuccess(response);
    final map = asMap(response.body);
    final message = resolveMessage(response, success);
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
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/items/${Uri.encodeComponent(id)}',
      requiresAuth: false,
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<ItemModel> createItem(CreateItemRequest itemRequest) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/items',
      requiresAuth: true,
      body: itemRequest.toJson(),
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<List<ItemModel>> getMyListings() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/items/my-listings',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      throw Exception(message);
    }

    return _parseItems(asMap(response.body));
  }

  Future<ItemModel> updateItem(String id, UpdateItemRequest itemRequest) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}',
      requiresAuth: true,
      body: itemRequest.toJson(),
    );

    final parsed = _parseSingleItemResponse(response);
    if (!parsed.success || parsed.item == null) {
      throw Exception(parsed.message);
    }
    return parsed.item!;
  }

  Future<bool> deleteItem(String id) async {
    final response = await request(
      method: ApiHttpMethod.delete,
      path: '/items/${Uri.encodeComponent(id)}',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    if (!success) {
      throw Exception(resolveMessage(response, false));
    }
    return true;
  }

  Future<ItemModel> pauseListing(String id) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/pause',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    if (!success) {
      throw Exception(resolveMessage(response, false));
    }
    // Patch the isPaused flag from the response data
    final map = asMap(response.body);
    final dataRaw = getByPath(map, 'data');
    final dataMap = dataRaw is Map ? stringKeyMap(dataRaw) : <String, dynamic>{};
    final isPaused = dataMap['isPaused'] as bool? ?? true;
    return _parsePausedItem(response, isPaused: isPaused);
  }

  Future<ItemModel> resumeListing(String id) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/resume',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    if (!success) {
      throw Exception(resolveMessage(response, false));
    }
    final map = asMap(response.body);
    final dataRaw = getByPath(map, 'data');
    final dataMap = dataRaw is Map ? stringKeyMap(dataRaw) : <String, dynamic>{};
    final isPaused = dataMap['isPaused'] as bool? ?? false;
    return _parsePausedItem(response, isPaused: isPaused);
  }

  /// The pause/resume endpoints only return `{ _id, isPaused }` inside `data`.
  /// We use the id to look up the full item and just patch the isPaused flag.
  ItemModel _parsePausedItem(Response<dynamic> response, {required bool isPaused}) {
    final map = asMap(response.body);
    final dataRaw = getByPath(map, 'data');
    final dataMap = dataRaw is Map ? stringKeyMap(dataRaw) : <String, dynamic>{};
    final id = dataMap['_id']?.toString().trim().isNotEmpty == true
        ? dataMap['_id'].toString().trim()
        : dataMap['id']?.toString().trim() ?? '';
    return ItemModel(id: id, isPaused: isPaused);
  }

  Future<List<String>> uploadItemPhotos(String id, List<File> photos) async {
    final files = photos
        .map(multipartFileFromPath)
        .toList(growable: false);

    final formData = FormData(<String, dynamic>{'photos': files});

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/items/${Uri.encodeComponent(id)}/photos',
      requiresAuth: true,
      body: formData,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    final map = asMap(response.body);

    if (!success) {
      throw Exception(message);
    }

    final photosList = toStringList(getByPath(map, 'data.photos'));
    return photosList;
  }

  Future<bool> deleteItemPhoto(String id, String photoUrl) async {
    final response = await request(
      method: ApiHttpMethod.deleteWithBody,
      path: '/items/${Uri.encodeComponent(id)}/photos',
      requiresAuth: true,
      body: <String, dynamic>{'photoUrl': photoUrl},
    );

    final success = resolveSuccess(response);
    if (!success) {
      throw Exception(resolveMessage(response, false));
    }
    return true;
  }

  Future<FormConfigModel> getFormConfig() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/items/form-config',
      requiresAuth: true,
    );
    final success = resolveSuccess(response);
    if (!success) throw Exception(resolveMessage(response, false));
    return FormConfigModel.fromJson(asMap(response.body));
  }

  Future<List<LanguageModel>> getLanguages() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/languages',
      requiresAuth: false,
    );
    final success = resolveSuccess(response);
    if (!success) throw Exception(resolveMessage(response, false));
    final map = asMap(response.body);
    final raw = getByPath(map, 'data');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => LanguageModel.fromJson(stringKeyMap(e)))
        .toList(growable: false);
  }

  Future<bool> updatePickupSchedule(String id, WeeklyScheduleModel schedule) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/pickup-schedule',
      requiresAuth: true,
      body: schedule.toJson(),
    );
    final success = resolveSuccess(response);
    if (!success) throw Exception(resolveMessage(response, false));
    return true;
  }

  Future<bool> updateDeliverySchedule(String id, WeeklyScheduleModel schedule) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/items/${Uri.encodeComponent(id)}/delivery-schedule',
      requiresAuth: true,
      body: schedule.toJson(),
    );
    final success = resolveSuccess(response);
    if (!success) throw Exception(resolveMessage(response, false));
    return true;
  }

  Future<BoostConfigModel> getBoostConfig() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/items/boost-config',
      requiresAuth: false,
    );
    final success = resolveSuccess(response);
    if (!success) throw Exception(resolveMessage(response, false));
    return BoostConfigModel.fromJson(asMap(response.body));
  }

  Future<BoostResult> boostItem(String id) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/items/${Uri.encodeComponent(id)}/boost',
      requiresAuth: true,
    );
    final statusCode = response.statusCode ?? 0;
    final map = asMap(response.body);
    final message = resolveMessage(response, statusCode >= 200 && statusCode < 300);

    if (statusCode == 402) {
      return BoostResult(success: false, message: message, noCredits: true);
    }

    final success = resolveSuccess(response);
    if (!success) return BoostResult(success: false, message: message);

    final data = getByPath(map, 'data') ?? map;
    final dataMap = data is Map ? stringKeyMap(data) : map;
    return BoostResult(
      success: true,
      message: message,
      isBoosted: dataMap['isBoosted'] as bool? ?? true,
      boostedAt: _asDateTimeLocal(dataMap['boostedAt']),
      boostExpiresAt: _asDateTimeLocal(dataMap['boostExpiresAt']),
    );
  }

  DateTime? _asDateTimeLocal(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
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

    final response = await request(
      method: ApiHttpMethod.put,
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

  _SingleItemResult _parseSingleItemResponse(Response<dynamic> response) {
    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    final map = asMap(response.body);

    if (!success) {
      return _SingleItemResult(success: false, message: message, item: null);
    }

    final candidates = <dynamic>[
      getByPath(map, 'data'),
      getByPath(map, 'item'),
      map,
    ];

    ItemModel? item;
    for (final candidate in candidates) {
      if (candidate is Map) {
        final candidateMap = stringKeyMap(candidate);
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
      getByPath(root, 'data'),
      getByPath(root, 'items'),
      getByPath(root, 'results'),
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((e) => ItemModel.fromJson(stringKeyMap(e)))
            .where((item) => item.id.trim().isNotEmpty)
            .toList(growable: false);
      }
    }

    return const <ItemModel>[];
  }

  PaginationModel? _parsePagination(Map<String, dynamic> root) {
    final raw = getByPath(root, 'pagination');
    if (raw is! Map) {
      return null;
    }
    return PaginationModel.fromJson(stringKeyMap(raw));
  }

  bool _looksLikeItem(Map<String, dynamic> map) {
    return map.containsKey('_id') ||
        map.containsKey('id') ||
        map.containsKey('title') ||
        map.containsKey('dailyRate') ||
        map.containsKey('category');
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
