import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/reviews/review_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/reviews/review_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.itemId, this.ownerId});

  final String itemId;
  final String? ownerId;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  int _selectedTab = 0; // 0 = Item Reviews, 1 = Owner Reviews
  late final ReviewController _reviewController;

  @override
  void initState() {
    super.initState();
    _reviewController = Get.isRegistered<ReviewController>()
        ? Get.find<ReviewController>()
        : Get.put(ReviewController());
    _reviewController.fetchItemReviews(widget.itemId, refresh: true);
    if ((widget.ownerId ?? '').isNotEmpty) {
      _reviewController.fetchOwnerReviews(widget.ownerId!, refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(
      init: _reviewController,
      builder: (controller) {
        final isOwnerTab = _selectedTab == 1;
        final hasOwner = (widget.ownerId ?? '').isNotEmpty;
        final currentReviews = isOwnerTab
            ? controller.ownerReviews
            : controller.itemReviews;
        final isLoading = isOwnerTab
            ? controller.isOwnerReviewsLoading
            : controller.isItemReviewsLoading;
        final errorMessage = isOwnerTab
            ? controller.ownerReviewsErrorMessage
            : controller.itemReviewsErrorMessage;

        return Scaffold(
          body: AnimatedListView(
            padding: EdgeInsets.all(20),
            children: [
              Gap(50),
              // Top Bar
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                  Gap(16),
                  MyText(text: "Reviews", size: 20, weight: FontWeight.w600),
                ],
              ),
              Gap(24),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kBlack.withOpacity(0.1), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Bounce(
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTab == 0
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: MyText(
                              text: 'Item Reviews',
                              size: 16,
                              color: _selectedTab == 0 ? kBlack : kSubText,
                              weight: _selectedTab == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Bounce(
                        onTap: hasOwner
                            ? () {
                                setState(() {
                                  _selectedTab = 1;
                                });
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTab == 1
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: MyText(
                              text: 'Owner Reviews',
                              size: 16,
                              color: _selectedTab == 1
                                  ? kBlack
                                  : (hasOwner ? kSubText : kSubText.withOpacity(0.5)),
                              weight: _selectedTab == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(24),

              if (isLoading && currentReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (errorMessage != null && currentReviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: MyText(
                      text: errorMessage,
                      size: 14,
                      color: kSubText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else ...[
                // Reviews count
                MyText(
                  text:
                      '${currentReviews.length} ${isOwnerTab ? 'Owner' : 'Item'} Reviews',
                  size: 16,
                  color: kSubText,
                  weight: FontWeight.w500,
                ),
                Gap(20),

                if (currentReviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: MyText(
                        text: 'No reviews yet.',
                        size: 14,
                        color: kSubText,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: currentReviews.length,
                    separatorBuilder: (context, index) => Gap(20),
                    itemBuilder: (context, index) {
                      return ReviewCard(review: currentReviews[index]);
                    },
                  ),
              ],
              Gap(20),
            ],
          ),
        );
      },
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  String get _timeAgo {
    final createdAt = review.createdAt;
    if (createdAt == null) {
      return '';
    }
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
    final reviewerName = review.reviewer?.fullName ?? 'Zip Rental user';
    final avatarPath = review.reviewer?.profilePhoto ?? Assets.imagesShoes2;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar, Name, Time, Rating
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kbackground,
                ),
                child: ClipOval(
                  child: CommonImageView(
                    imagePath: avatarPath,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Gap(12),
              // Name and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: reviewerName,
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                    Gap(4),
                    MyText(text: _timeAgo, size: 14, color: kSubText),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  CommonImageView(imagePath: Assets.imagesStar, height: 20),
                  Gap(4),
                  MyText(
                    text: "${review.rating ?? 0}",
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          Gap(6),
          Divider(color: kDividerColor),
          Gap(6),
          // Comment Text
          MyText(text: review.comment ?? '', size: 14, color: kSubText),
        ],
      ),
    );
  }
}
