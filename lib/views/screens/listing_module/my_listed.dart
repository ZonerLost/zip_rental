import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/bottom_nav_controller.dart';
import 'package:zip_peer/controllers/items/my_listings_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/listing_module/item_details.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class MyListedItemsScreen extends StatelessWidget {
  const MyListedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyListingsController>(
      init: MyListingsController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                children: [
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: 'My Listings',
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                      Bounce(
                        onTap: () {
                          BottomNavController.to.switchTo(2);
                        },
                        child: CommonImageView(
                          imagePath: Assets.imagesNavAdd,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : controller.listings.isEmpty
                        ? const _EmptyListingsView()
                        : RefreshIndicator(
                            onRefresh: controller.fetchMyListings,
                            child: ListView.builder(
                              itemCount: controller.listings.length,
                              itemBuilder: (context, index) {
                                final item = controller.listings[index];
                                return _ListingCard(
                                  item: item,
                                  onOpen: () {
                                    Get.to(
                                      () => ListingItemDetailsScreen(
                                        itemId: item.id,
                                      ),
                                    );
                                  },
                                  onTogglePause: () =>
                                      controller.togglePause(item.id),
                                );
                              },
                            ),
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
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.item,
    required this.onOpen,
    required this.onTogglePause,
  });

  final ItemModel item;
  final VoidCallback onOpen;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    final isPaused = item.isPaused ?? false;
    final image = item.thumbnailUrl;
    final hasImage =
        image.startsWith('http://') || image.startsWith('https://');

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPaused ? kPrimaryColor : Colors.transparent,
            width: 2,
          ),
          color: isPaused ? kPrimaryColor.withOpacity(0.1) : kWhite,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CommonImageView(
                      imagePath: hasImage ? null : Assets.imagesShoes1,
                      url: hasImage ? image : null,
                      placeHolder: Assets.imagesShoes1,
                      height: 60,
                      width: 60,
                      radius: 10,
                    ),
                    const Gap(12),
                    SizedBox(
                      width: Get.width * 0.45,
                      child: MyText(
                        text: item.title ?? 'Untitled',
                        size: 18,
                        weight: FontWeight.w600,
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
            const Gap(16),
            _buildDetailRow('Category', item.category ?? '-'),
            const Gap(12),
            _buildDetailRow('Condition', item.condition ?? '-'),
            const Gap(12),
            _buildDetailRow(
              'Price',
              '${item.currency ?? 'CAD'} ${(item.dailyRate ?? 0).toStringAsFixed(2)}/day',
            ),
            const Gap(12),
            _buildDetailRow('Address', item.location?.fullLocation ?? '-'),
            const Gap(12),
            _buildDetailRow(
              'Status',
              (item.isActive ?? true) ? 'Active' : 'Inactive',
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: isPaused ? 'Resume listing' : 'Pause listing',
                  size: 16,
                  weight: FontWeight.w500,
                  color: kPrimaryColor,
                ),
                Switch(
                  value: isPaused,
                  onChanged: (_) => onTogglePause(),
                  activeColor: kPrimaryColor,
                  inactiveTrackColor: kWhite,
                  inactiveThumbColor: kBlack,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(text: label, size: 14, color: kSubText),
        SizedBox(
          width: Get.width * 0.5,
          child: MyText(
            text: value,
            size: 14,
            weight: FontWeight.w600,
            textAlign: TextAlign.end,
            maxLines: 2,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyListingsView extends StatelessWidget {
  const _EmptyListingsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyText(
        text: 'No listings found.',
        size: 16,
        color: kSubText,
        weight: FontWeight.w500,
      ),
    );
  }
}
