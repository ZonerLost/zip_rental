// ignore_for_file: prefer_final_fields

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/items/item_details_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/home/item_detail/check_out_2.dart';
import 'package:zip_peer/views/screens/home/item_detail/comments.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _monthCount = 1;
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemDetailsController>(
      init: ItemDetailsController(itemId: widget.itemId),
      builder: (controller) {
        final item = controller.item;

        return Scaffold(
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text:
                                '${item?.currency ?? 'CAD'} ${(item?.dailyRate ?? 0).toStringAsFixed(2)}',
                            size: 24,
                            weight: FontWeight.w700,
                          ),
                          MyText(
                            text: 'Total amount',
                            size: 14,
                            color: kSubText,
                          ),
                        ],
                      ),
                      const Gap(20),
                      Expanded(
                        child: MyButton(
                          onTap: () {
                            Get.to(() => const CheckoutScreen2());
                          },
                          buttonText: 'Book Now',
                          height: 56,
                          radius: 30,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
              ? _ErrorView(
                  message: controller.errorMessage!,
                  onRetry: controller.fetchItem,
                )
              : item == null
              ? const _ErrorView(message: 'Item not found')
              : _buildContent(item),
        );
      },
    );
  }

  Widget _buildContent(ItemModel item) {
    final photos = item.photos;
    final hasPhotos = photos.isNotEmpty;

    final ownerPhoto = item.owner?.profilePhoto ?? '';
    final hasOwnerPhoto =
        ownerPhoto.startsWith('http://') || ownerPhoto.startsWith('https://');

    final locationText = item.location?.fullLocation.isNotEmpty == true
        ? item.location!.fullLocation
        : 'Location unavailable';

    return AnimatedListView(
      padding: const EdgeInsets.all(10),
      children: [
        const Gap(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Bounce(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: kWhite,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 24),
              ),
            ),
            Bounce(
              onTap: () {},
              child: CommonImageView(
                imagePath: Assets.imagesHeartIcon,
                height: 50,
              ),
            ),
          ],
        ),
        const Gap(20),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SizedBox(
                  height: 350,
                  child: hasPhotos
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: photos.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return CommonImageView(
                              height: 350,
                              width: double.infinity,
                              url: photos[index],
                              fit: BoxFit.cover,
                              placeHolder: Assets.imagesShoes1,
                            );
                          },
                        )
                      : CommonImageView(
                          height: 350,
                          width: double.infinity,
                          imagePath: Assets.imagesShoes1,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      hasPhotos ? photos.length.clamp(0, 5) : 1,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentImageIndex ? 25 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: MyText(
                      text:
                          '${hasPhotos ? _currentImageIndex + 1 : 1}/${hasPhotos ? photos.length : 1}',
                      size: 14,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Bounce(
                      onTap: () {
                        if (_monthCount > 1) {
                          setState(() {
                            _monthCount--;
                          });
                        }
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesMinusItemDetail,
                        height: 50,
                      ),
                    ),
                    MyText(
                      text: '${_monthCount.toString().padLeft(2, '0')} Month',
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                    Bounce(
                      onTap: () {
                        setState(() {
                          _monthCount++;
                        });
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesAddItemDetail,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: item.title ?? 'Untitled item',
                          size: 24,
                          weight: FontWeight.w700,
                        ),
                        const Gap(8),
                        MyText(
                          text:
                              '${item.totalRentals ?? 0} Times rented | ${item.condition ?? 'n/a'}',
                          size: 14,
                          color: kSubText,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyText(
                        text:
                            '${item.currency ?? 'CAD'} ${(item.dailyRate ?? 0).toStringAsFixed(2)}',
                        size: 20,
                        weight: FontWeight.w700,
                      ),
                      MyText(text: '/ day', size: 14, color: kSubText),
                    ],
                  ),
                ],
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CommonImageView(
                          imagePath: hasOwnerPhoto
                              ? null
                              : Assets.imagesChatAvatar,
                          url: hasOwnerPhoto ? ownerPhoto : null,
                          placeHolder: Assets.imagesChatAvatar,
                          height: 40,
                          width: 40,
                          radius: 20,
                        ),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: item.ownerName,
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                            const Gap(4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const Gap(4),
                                MyText(
                                  text:
                                      '${(item.owner?.averageRating ?? item.averageRating ?? 0).toStringAsFixed(1)} ratings',
                                  size: 14,
                                  color: kBlack,
                                ),
                                const Gap(12),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Bounce(
                      onTap: () {
                        Get.to(() => const CommentsScreen());
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesCommentsNewIcon,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              MyText(
                text: (item.description ?? '').isNotEmpty
                    ? item.description!
                    : 'No description available.',
                size: 14,
                color: kSubText,
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: 'Available Options',
                      size: 18,
                      weight: FontWeight.w700,
                    ),
                    const Gap(16),
                    MyText(
                      text: (item.availability?.isAvailable ?? true)
                          ? 'Available for booking'
                          : 'Currently unavailable',
                      size: 16,
                      color: kBlack,
                    ),
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kWhite3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: kPrimaryColor,
                            size: 24,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: 'Approximate pickup location',
                                  size: 14,
                                  weight: FontWeight.w600,
                                ),
                                const Gap(4),
                                MyText(
                                  text: locationText,
                                  size: 12,
                                  color: kSubText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((item.availability?.blockedDates ?? const <String>[])
                        .isNotEmpty) ...[
                      const Gap(14),
                      MyText(
                        text:
                            'Blocked dates: ${item.availability!.blockedDates.join(', ')}',
                        size: 12,
                        color: kSubText,
                      ),
                    ],
                    // TODO: If S3 returns AccessDenied for image URLs, backend should return public URLs or signed URLs.
                  ],
                ),
              ),
              const Gap(50),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(
              text: message,
              size: 14,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(12),
              Bounce(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MyText(
                    text: 'Retry',
                    size: 13,
                    color: kPrimaryColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
