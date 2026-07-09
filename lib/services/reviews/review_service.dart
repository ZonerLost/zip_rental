import 'package:get/get.dart';
import 'package:zip_peer/models/reviews/review_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class ReviewService extends ApiServiceBase {
  ReviewService({AuthService? authService}) : super(authService: authService);

  Future<ReviewModel> submitReview(CreateReviewRequestModel requestModel) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/reviews',
      requiresAuth: true,
      body: requestModel.toJson(),
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      throw Exception(message);
    }

    final data = _dataMap(response);
    final review = ReviewModel.fromJson(data);
    if (review.id.trim().isEmpty) {
      throw Exception(message);
    }
    return review;
  }

  Future<PaginatedReviewsResponse> getUserReviews(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    return _getReviewsList(
      '/reviews/user/${Uri.encodeComponent(userId)}',
      requiresAuth: false,
      page: page,
      limit: limit,
    );
  }

  Future<PaginatedReviewsResponse> getItemReviews(
    String itemId, {
    int page = 1,
    int limit = 10,
  }) async {
    return _getReviewsList(
      '/reviews/item/${Uri.encodeComponent(itemId)}',
      requiresAuth: false,
      page: page,
      limit: limit,
    );
  }

  Future<PaginatedReviewsResponse> getMyReviews({
    int page = 1,
    int limit = 10,
  }) async {
    return _getReviewsList('/reviews/my', requiresAuth: true, page: page, limit: limit);
  }

  Future<List<PendingReviewModel>> getPendingReviews() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/reviews/pending',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      throw Exception(message);
    }

    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    if (data is! List) {
      return const <PendingReviewModel>[];
    }

    return data
        .whereType<Map>()
        .map((entry) => PendingReviewModel.fromJson(stringKeyMap(entry)))
        .where((pending) => pending.bookingId.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<PaginatedReviewsResponse> _getReviewsList(
    String path, {
    required bool requiresAuth,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: path,
      requiresAuth: requiresAuth,
      query: <String, dynamic>{
        'page': page.toString(),
        'limit': limit.clamp(1, 50).toString(),
      },
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    final root = asMap(response.body);

    if (!success) {
      return PaginatedReviewsResponse(success: false, message: message);
    }

    final data = getByPath(root, 'data');
    final reviews = data is List
        ? data
              .whereType<Map>()
              .map((entry) => ReviewModel.fromJson(stringKeyMap(entry)))
              .where((review) => review.id.trim().isNotEmpty)
              .toList(growable: false)
        : const <ReviewModel>[];

    final paginationRaw = getByPath(root, 'pagination');
    final pagination = paginationRaw is Map
        ? ReviewPaginationModel.fromJson(stringKeyMap(paginationRaw))
        : null;

    return PaginatedReviewsResponse(
      success: true,
      message: message,
      reviews: reviews,
      pagination: pagination,
    );
  }

  Map<String, dynamic> _dataMap(Response<dynamic> response) {
    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    if (data is Map) {
      return stringKeyMap(data);
    }
    return <String, dynamic>{};
  }
}
