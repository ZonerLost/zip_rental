import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/favourites/favourites_controller.dart';
import 'package:zip_peer/controllers/items/browse_items_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kWhite,
          borderRadius: BorderRadius.circular(25),
        ),
        child: MyText(
          text: label,
          size: 16,
          weight: FontWeight.w600,
          color: isSelected ? kWhite : kSubText,
        ),
      ),
    );
  }
}

class HeaderRow2 extends StatelessWidget {
  const HeaderRow2({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrowseItemsController>(
      builder: (controller) {
        final categoryLabel =
            controller.category?.isNotEmpty == true
                ? controller.category!
                : 'All';

        final locationLabel =
            controller.city?.isNotEmpty == true ? controller.city! : 'All';

        final distanceLabel = controller.distance != null
            ? controller.distance! < 1
                ? '${(controller.distance! * 1000).toInt()} m'
                : '${controller.distance!.toStringAsFixed(controller.distance! % 1 == 0 ? 0 : 1)} km'
            : 'All';

        return Row(
          children: [
            Expanded(
              child: Bounce(
                onTap: () => showFiltersBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesCategoryFootwear,
                        height: 16,
                      ),
                      Flexible(
                        child: MyText(
                          text: categoryLabel,
                          size: 14,
                          weight: FontWeight.w400,
                          color: kBlack,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Bounce(
                onTap: () => showFiltersBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesDiscover,
                        height: 16,
                      ),
                      Flexible(
                        child: MyText(
                          text: locationLabel,
                          size: 14,
                          weight: FontWeight.w400,
                          color: kBlack,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Bounce(
                onTap: () => showFiltersBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesDiscover,
                        height: 16,
                      ),
                      Flexible(
                        child: MyText(
                          text: distanceLabel,
                          size: 14,
                          weight: FontWeight.w400,
                          color: kBlack,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SneakerCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String userName;
  final String avatarUrl;
  final String? itemId;

  const SneakerCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.userName,
    required this.avatarUrl,
    this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    final hasNetworkAvatar =
        avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://');

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CommonImageView(
                    imagePath: hasNetworkImage ? null : imageUrl,
                    url: hasNetworkImage ? imageUrl : null,
                    fit: BoxFit.cover,
                    height: 240,
                    width: 200,
                  ),
                ),

                // Heart icon
                if (itemId != null)
                  Positioned(
                    top: 5,
                    right: 10,
                    child: GetBuilder<FavouritesController>(
                      builder: (favCtrl) {
                        final isFav = favCtrl.isFavourite(itemId!);
                        return Bounce(
                          onTap: () => favCtrl.toggle(FavItem(
                            id: itemId!,
                            title: title,
                            price: price,
                            imageUrl: imageUrl,
                            ownerName: userName,
                            ownerPhoto: avatarUrl,
                          )),
                          child: CommonImageView(
                            imagePath: isFav
                                ? Assets.imagesHeartFilled
                                : Assets.imagesHeartEmpty,
                            height: 30,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Positioned(
                    top: 5,
                    right: 10,
                    child: CommonImageView(
                      imagePath: Assets.imagesHeartEmpty,
                      height: 30,
                    ),
                  ),

                Positioned(
                  bottom: 10,
                  right: 10,
                  left: 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CommonImageView(
                              imagePath: hasNetworkAvatar ? null : avatarUrl,
                              url: hasNetworkAvatar ? avatarUrl : null,
                              height: 30,
                              width: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: userName,
                                    size: 14,
                                    color: kBlack,
                                    weight: FontWeight.w500,
                                    maxLines: 1,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: i == 0 ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: title,
                size: 16,
                color: kBlack,
                weight: FontWeight.w500,
              ),
              Row(
                children: [
                  MyText(
                    text: price,
                    size: 14,
                    color: kBlack,
                    weight: FontWeight.w500,
                  ),
                  MyText(
                    text: "/month",
                    size: 14,
                    color: kSubText,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
