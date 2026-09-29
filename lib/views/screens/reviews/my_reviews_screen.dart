import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/reviews/review_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/reviews/review_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

/// `GET /reviews/my` — every review the signed-in user has authored, across
/// all three types (rated an owner, rated an item, rated a renter). The
/// endpoint already existed in `ReviewService` but had no screen consuming
/// it until now.
class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  late final ReviewController _reviewController;

  @override
  void initState() {
    super.initState();
    _reviewController = Get.isRegistered<ReviewController>()
        ? Get.find<ReviewController>()
        : Get.put(ReviewController());
    _reviewController.fetchMyReviews(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(
      init: _reviewController,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  Row(
                    children: [
                      Bounce(
                        onTap: () => Get.back(),
                        child: CommonImageView(
                          imagePath: Assets.imagesBack,
                          height: 50,
                        ),
                      ),
                      const Gap(10),
                      const MyText(
                        text: 'My Reviews',
                        size: 16,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _reviewController.fetchMyReviews(refresh: true),
                      child: _buildBody(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ReviewController controller) {
    if (controller.isMyReviewsLoading && controller.myReviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((controller.myReviewsErrorMessage ?? '').isNotEmpty && controller.myReviews.isEmpty) {
      return ListView(
        children: [
          const Gap(60),
          MyText(
            text: controller.myReviewsErrorMessage!,
            size: 14,
            color: kredColor,
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Center(
            child: Bounce(
              onTap: () => controller.fetchMyReviews(refresh: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const MyText(
                  text: 'Retry',
                  size: 13,
                  color: kPrimaryColor,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (controller.myReviews.isEmpty) {
      return ListView(
        children: const [
          Gap(80),
          Center(
            child: MyText(
              text: "You haven't written any reviews yet.",
              size: 14,
              color: kSubText,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: controller.myReviews.length + 1,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        if (index == controller.myReviews.length) {
          if (!controller.myReviewsHasNext) return const SizedBox.shrink();
          if (!controller.isMyReviewsLoading) controller.fetchMyReviews();
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _MyReviewCard(review: controller.myReviews[index]);
      },
    );
  }
}

class _MyReviewCard extends StatelessWidget {
  const _MyReviewCard({required this.review});

  final ReviewModel review;

  /// What this review was *about*, since "reviewer" is always the current
  /// user here and isn't worth showing again.
  String get _targetLabel {
    switch (review.type) {
      case ReviewTypes.renterToOwner:
        return 'You rated ${review.reviewee?.fullName ?? "the owner"}';
      case ReviewTypes.ownerToRenter:
        return 'You rated ${review.reviewee?.fullName ?? "the renter"}';
      case ReviewTypes.renterToItem:
        return 'You rated ${review.item?.title ?? "the item"}';
      default:
        return 'Your review';
    }
  }

  String get _timeAgo {
    final createdAt = review.createdAt;
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MyText(
                  text: _targetLabel,
                  size: 15,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  CommonImageView(imagePath: Assets.imagesStar, height: 18),
                  const Gap(4),
                  MyText(
                    text: '${review.rating ?? 0}',
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          if (review.type == ReviewTypes.renterToOwner || review.type == ReviewTypes.ownerToRenter)
            if ((review.item?.title ?? '').isNotEmpty) ...[
              const Gap(2),
              MyText(text: 'For "${review.item!.title}"', size: 12, color: kSubText2),
            ],
          const Gap(6),
          MyText(text: _timeAgo, size: 12, color: kSubText),
          if ((review.comment ?? '').isNotEmpty) ...[
            const Gap(8),
            Divider(color: kDividerColor),
            const Gap(8),
            MyText(text: review.comment!, size: 14, color: kSubText),
          ],
        ],
      ),
    );
  }
}
