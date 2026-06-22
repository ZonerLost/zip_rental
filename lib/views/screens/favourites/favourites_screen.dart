import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/favourites/favourites_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/home/item_detail/add_item.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouritesController>(
      builder: (controller) {
        final items = controller.items;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Bounce(
                        onTap: Get.back,
                        child: CommonImageView(
                          imagePath: Assets.imagesBack,
                          height: 44,
                        ),
                      ),
                      const Gap(12),
                      const MyText(
                        text: 'Favourites',
                        size: 20,
                        weight: FontWeight.w600,
                        color: kBlack,
                      ),
                      const Spacer(),
                      MyText(
                        text: '${items.length} items',
                        size: 13,
                        color: kSubText,
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                if (items.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonImageView(
                            imagePath: Assets.imagesHeartEmpty,
                            height: 64,
                          ),
                          const Gap(16),
                          const MyText(
                            text: 'No favourites yet',
                            size: 16,
                            weight: FontWeight.w600,
                            color: kBlack,
                          ),
                          const Gap(8),
                          const MyText(
                            text: 'Tap the heart on any item to save it here',
                            size: 14,
                            color: kSubText,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _FavCard(item: item, controller: controller);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FavCard extends StatelessWidget {
  const _FavCard({required this.item, required this.controller});

  final FavItem item;
  final FavouritesController controller;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = item.imageUrl.startsWith('http');
    final hasNetworkAvatar = item.ownerPhoto.startsWith('http');

    return Bounce(
      onTap: () => Get.to(() => ItemDetailsScreen(itemId: item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CommonImageView(
                  imagePath: hasNetworkImage ? null : Assets.imagesShoes1,
                  url: hasNetworkImage ? item.imageUrl : null,
                  placeHolder: Assets.imagesShoes1,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 10,
                child: Bounce(
                  onTap: () => controller.toggle(item),
                  child: CommonImageView(
                    imagePath: Assets.imagesHeartFilled,
                    height: 30,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          MyText(
            text: item.title,
            size: 13,
            color: kBlack,
            weight: FontWeight.w600,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
          const Gap(4),
          Row(
            children: [
              if (hasNetworkAvatar)
                ClipOval(
                  child: CommonImageView(
                    url: item.ownerPhoto,
                    height: 18,
                    width: 18,
                    fit: BoxFit.cover,
                  ),
                )
              else
                CommonImageView(
                  imagePath: Assets.imagesChatAvatar,
                  height: 18,
                  width: 18,
                  radius: 9,
                ),
              const Gap(6),
              Expanded(
                child: MyText(
                  text: item.ownerName.isEmpty ? 'Owner' : item.ownerName,
                  size: 12,
                  color: kSubText,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(4),
          MyText(
            text: item.price,
            size: 13,
            color: kBlack,
            weight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
