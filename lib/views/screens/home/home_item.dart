import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/favourites/favourites_controller.dart';
import 'package:zip_peer/controllers/items/browse_items_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/home/item_detail/add_item.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class HomeItemScreen extends StatefulWidget {
  const HomeItemScreen({super.key});

  @override
  State<HomeItemScreen> createState() => _HomeItemScreenState();
}

class _HomeItemScreenState extends State<HomeItemScreen> {
  final ScrollController _scrollController = ScrollController();
  late final BrowseItemsController _browseController;

  @override
  void initState() {
    super.initState();
    _browseController = Get.isRegistered<BrowseItemsController>()
        ? Get.find<BrowseItemsController>()
        : Get.put(BrowseItemsController());
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _browseController.maybeLoadMore(_scrollController.position);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrowseItemsController>(
      init: _browseController,
      builder: (controller) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: controller.refreshItems,
            child: AnimatedListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(50),
                Row(
                  children: [
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 42,
                        width: 42,
                      ),
                    ),
                    const Gap(12),
                    MyText(
                      text: controller.category ?? 'Browse Items',
                      size: 20,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(25),
                Row(
                  children: [
                    MyText(
                      text: '${controller.items.length} Results found',
                      size: 14,
                      color: kSubText,
                      weight: FontWeight.w500,
                    ),
                    if ((controller.search ?? '').isNotEmpty) ...[
                      MyText(
                        text: ' for ',
                        size: 14,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      MyText(
                        text: controller.search ?? '',
                        size: 14,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ],
                ),
                const Gap(20),
                if (controller.isLoadingInitial)
                  const Center(child: CircularProgressIndicator())
                else if (controller.errorMessage != null &&
                    controller.items.isEmpty)
                  _ErrorView(
                    message: controller.errorMessage!,
                    onRetry: () => controller.loadItems(reset: true),
                  )
                else if (controller.items.isEmpty)
                  const _EmptyView()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.items.length,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.56,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                        ),
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      return _SneakerGridCard(item: item);
                    },
                  ),
                if (controller.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SneakerGridCard extends StatelessWidget {
  const _SneakerGridCard({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl;
    final hasNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    final avatarUrl = item.owner?.profilePhoto ?? '';
    final hasNetworkAvatar =
        avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://');

    return Bounce(
      onTap: () {
        Get.to(() => ItemDetailsScreen(itemId: item.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CommonImageView(
                  imagePath: hasNetworkImage ? null : Assets.imagesShoes1,
                  url: hasNetworkImage ? imageUrl : null,
                  placeHolder: Assets.imagesShoes1,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 10,
                child: GetBuilder<FavouritesController>(
                  builder: (favCtrl) {
                    final isFav = favCtrl.isFavourite(item.id);
                    return Bounce(
                      onTap: () => favCtrl.toggle(FavItem(
                        id: item.id,
                        title: item.title ?? '',
                        price:
                            '${item.currency ?? 'CAD'} ${item.dailyRate?.toStringAsFixed(2) ?? '0.00'}',
                        imageUrl: item.thumbnailUrl,
                        ownerName: item.ownerName,
                        ownerPhoto: item.owner?.profilePhoto ?? '',
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
              ),
              Positioned(
                bottom: 10,
                right: 10,
                left: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          CommonImageView(
                            imagePath: hasNetworkAvatar
                                ? null
                                : Assets.imagesChatAvatar,
                            url: hasNetworkAvatar ? avatarUrl : null,
                            placeHolder: Assets.imagesChatAvatar,
                            height: 25,
                            width: 25,
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: item.ownerName,
                                  size: 12,
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
                    Row(
                      children: List.generate(3, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == 0 ? 20 : 8,
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
          const Gap(8),
          MyText(
            text: item.title ?? 'Untitled',
            size: 14,
            color: kBlack,
            weight: FontWeight.w600,
          ),
          const Gap(4),
          Row(
            children: [
              Flexible(
                child: MyText(
                  text:
                      '${item.currency ?? 'CAD'} ${item.dailyRate?.toStringAsFixed(2) ?? '0.00'}',
                  size: 14,
                  color: kBlack,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              MyText(
                text: ' /day',
                size: 12,
                color: kSubText,
                weight: FontWeight.w400,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: MyText(
          text: 'No items found.',
          size: 16,
          color: kSubText,
          weight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          MyText(
            text: message,
            size: 14,
            color: Colors.red,
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Bounce(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      ),
    );
  }
}
