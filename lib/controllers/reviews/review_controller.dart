import 'package:get/get.dart';
import 'package:zip_peer/models/reviews/review_models.dart';
import 'package:zip_peer/services/reviews/review_service.dart';

class ReviewController extends GetxController {
  ReviewController({ReviewService? reviewService})
    : _reviewService = reviewService ?? ReviewService();

  final ReviewService _reviewService;
  static const int _pageSize = 10;

  bool isItemReviewsLoading = false;
  bool isOwnerReviewsLoading = false;
  bool isPendingReviewsLoading = false;
  bool isSubmitReviewLoading = false;

  String? itemReviewsErrorMessage;
  String? ownerReviewsErrorMessage;
  String? pendingReviewsErrorMessage;

  final List<ReviewModel> itemReviews = <ReviewModel>[];
  final List<ReviewModel> ownerReviews = <ReviewModel>[];
  final List<PendingReviewModel> pendingReviews = <PendingReviewModel>[];

  int itemReviewsPage = 1;
  bool itemReviewsHasNext = false;
  int ownerReviewsPage = 1;
  bool ownerReviewsHasNext = false;

  Future<void> fetchItemReviews(String itemId, {bool refresh = false}) async {
    if (refresh) {
      itemReviewsPage = 1;
      itemReviewsHasNext = false;
      itemReviews.clear();
    } else if (isItemReviewsLoading ||
        (itemReviews.isNotEmpty && !itemReviewsHasNext)) {
      return;
    }

    isItemReviewsLoading = true;
    itemReviewsErrorMessage = null;
    update();

    final result = await _reviewService.getItemReviews(
      itemId,
      page: itemReviewsPage,
      limit: _pageSize,
    );

    isItemReviewsLoading = false;
    if (!result.success) {
      itemReviewsErrorMessage = result.message;
      update();
      return;
    }

    if (refresh) {
      itemReviews
        ..clear()
        ..addAll(result.reviews);
    } else {
      itemReviews.addAll(result.reviews);
    }

    final pagination = result.pagination;
    itemReviewsHasNext =
        pagination?.hasNext ?? (result.reviews.length >= _pageSize);
    itemReviewsPage = (pagination?.page ?? itemReviewsPage) + 1;
    update();
  }

  Future<void> fetchOwnerReviews(String ownerId, {bool refresh = false}) async {
    if (refresh) {
      ownerReviewsPage = 1;
      ownerReviewsHasNext = false;
      ownerReviews.clear();
    } else if (isOwnerReviewsLoading ||
        (ownerReviews.isNotEmpty && !ownerReviewsHasNext)) {
      return;
    }

    isOwnerReviewsLoading = true;
    ownerReviewsErrorMessage = null;
    update();

    final result = await _reviewService.getUserReviews(
      ownerId,
      page: ownerReviewsPage,
      limit: _pageSize,
    );

    isOwnerReviewsLoading = false;
    if (!result.success) {
      ownerReviewsErrorMessage = result.message;
      update();
      return;
    }

    if (refresh) {
      ownerReviews
        ..clear()
        ..addAll(result.reviews);
    } else {
      ownerReviews.addAll(result.reviews);
    }

    final pagination = result.pagination;
    ownerReviewsHasNext =
        pagination?.hasNext ?? (result.reviews.length >= _pageSize);
    ownerReviewsPage = (pagination?.page ?? ownerReviewsPage) + 1;
    update();
  }

  Future<void> fetchPendingReviews() async {
    isPendingReviewsLoading = true;
    pendingReviewsErrorMessage = null;
    update();

    try {
      final result = await _reviewService.getPendingReviews();
      pendingReviews
        ..clear()
        ..addAll(result);
    } catch (e) {
      pendingReviewsErrorMessage = _readMessage(e);
    }

    isPendingReviewsLoading = false;
    update();
  }

  Future<bool> submitReview({
    required String bookingId,
    required String type,
    required int rating,
    required String comment,
  }) async {
    isSubmitReviewLoading = true;
    update();

    try {
      await _reviewService.submitReview(
        CreateReviewRequestModel(
          bookingId: bookingId,
          type: type,
          rating: rating,
          comment: comment,
        ),
      );
      pendingReviews.removeWhere((pending) {
        if (pending.bookingId != bookingId) {
          return false;
        }
        pending.pendingTypes.remove(type);
        return pending.pendingTypes.isEmpty;
      });
      Get.snackbar('Success', 'Review submitted successfully.');
      return true;
    } catch (e) {
      Get.snackbar('Review Failed', _readMessage(e));
      return false;
    } finally {
      isSubmitReviewLoading = false;
      update();
    }
  }

  String _readMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
