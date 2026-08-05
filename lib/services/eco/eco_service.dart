import 'package:get/get.dart';
import 'package:zip_peer/models/eco/eco_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class EcoResult<T> {
  const EcoResult({required this.success, required this.message, this.data});

  final bool success;
  final String message;
  final T? data;
}

class EcoService extends ApiServiceBase {
  EcoService({AuthService? authService}) : super(authService: authService);

  /// 6.1 — GET /eco/my-impact (auth required).
  /// [period] is optional: `month` or `year` for period-specific stats.
  Future<EcoResult<MyEcoImpactModel>> getMyImpact({String? period}) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/eco/my-impact',
      requiresAuth: true,
      query: <String, dynamic>{
        if ((period ?? '').trim().isNotEmpty) 'period': period!.trim(),
      },
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      return EcoResult(success: false, message: message);
    }

    return EcoResult(
      success: true,
      message: message,
      data: MyEcoImpactModel.fromJson(_dataMap(response)),
    );
  }

  /// 6.2 — GET /eco/booking/:bookingId (auth required).
  Future<EcoResult<BookingEcoImpactModel>> getBookingImpact(
    String bookingId,
  ) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/eco/booking/${Uri.encodeComponent(bookingId)}',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: 'No eco impact recorded for this booking yet.',
    );
    if (!success) {
      return EcoResult(success: false, message: message);
    }

    return EcoResult(
      success: true,
      message: message,
      data: BookingEcoImpactModel.fromJson(_dataMap(response)),
    );
  }

  /// 6.3 — GET /eco/leaderboard/users (public).
  Future<EcoResult<List<EcoLeaderboardUserModel>>> getUserLeaderboard({
    int limit = 10,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/eco/leaderboard/users',
      requiresAuth: false,
      query: <String, dynamic>{'limit': limit.clamp(1, 50).toString()},
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      return EcoResult(success: false, message: message);
    }

    final list = _dataList(response)
        .map((entry) => EcoLeaderboardUserModel.fromJson(entry))
        .toList(growable: false);
    return EcoResult(success: true, message: message, data: list);
  }

  /// 6.4 — GET /eco/leaderboard/cities (public).
  Future<EcoResult<List<EcoLeaderboardCityModel>>> getCityLeaderboard({
    int limit = 10,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/eco/leaderboard/cities',
      requiresAuth: false,
      query: <String, dynamic>{'limit': limit.clamp(1, 50).toString()},
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      return EcoResult(success: false, message: message);
    }

    final list = _dataList(response)
        .map((entry) => EcoLeaderboardCityModel.fromJson(entry))
        .toList(growable: false);
    return EcoResult(success: true, message: message, data: list);
  }

  /// 6.5 — GET /eco/categories (public).
  Future<EcoResult<List<EcoCategoryModel>>> getCategories() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/eco/categories',
      requiresAuth: false,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      return EcoResult(success: false, message: message);
    }

    final list = _dataList(response)
        .map((entry) => EcoCategoryModel.fromJson(entry))
        .toList(growable: false);
    return EcoResult(success: true, message: message, data: list);
  }

  Map<String, dynamic> _dataMap(Response<dynamic> response) {
    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    if (data is Map) {
      return stringKeyMap(data);
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _dataList(Response<dynamic> response) {
    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    if (data is! List) {
      return const <Map<String, dynamic>>[];
    }
    return data
        .whereType<Map>()
        .map((entry) => stringKeyMap(entry))
        .toList(growable: false);
  }
}
