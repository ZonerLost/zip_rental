import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/favourites/favourites_controller.dart';
import 'package:zip_peer/controllers/items/browse_items_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/favourites/favourites_screen.dart';
import 'package:zip_peer/views/screens/home/home_explore.dart';
import 'package:zip_peer/views/screens/home/home_item.dart';
import 'package:zip_peer/views/screens/home/home_widgets.dart';
import 'package:zip_peer/views/screens/home/item_detail/add_item.dart';
import 'package:zip_peer/views/screens/notifications/notifications.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late final BrowseItemsController _browseController;

  @override
  void initState() {
    super.initState();
    Get.put(FavouritesController());
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
          body: AnimatedListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              const Gap(50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: 'Welcome Back!',
                        size: 14,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      MyText(
                        text: 'Explore Rentals',
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Bounce(
                        onTap: () => Get.to(() => const FavouritesScreen()),
                        child: CommonImageView(
                          imagePath: Assets.imagesHeartIcon,
                          height: 50,
                        ),
                      ),
                      const Gap(10),
                      Bounce(
                        onTap: () {
                          Get.to(() => const NotificationScreen());
                        },
                        child: CommonImageView(
                          imagePath: Assets.imagesNotificationIcon,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(20),
              MyTextField(
                backgroundColor: kWhite,
                hint: 'What tools are you looking for ...',
                hintColor: kSubText2,
                isObSecure: false,
                radius: 25,
                hintsize: 12,
                hintWeight: FontWeight.w400,
                onChanged: controller.setSearchQuery,
                prefix: CommonImageView(
                  imagePath: Assets.imagesMynauiSearch,
                  height: 24,
                ),
                suffix: Bounce(
                  onTap: () {
                    Get.to(() => const HomeExploreScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: kPrimaryColor.withOpacity(0.2),
                    ),
                    child: MyText(
                      text: 'Explore on Map',
                      size: 12,
                      weight: FontWeight.w400,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const Gap(10),
              const HeaderRow2(),
              const Gap(20),
              if (controller.search?.isNotEmpty == true ||
                  controller.hasActiveFilters)
                // ── Search / filter results ──────────────────────────────────
                _buildSearchResults(controller)
              else ...[
                // ── Normal feed ──────────────────────────────────────────────
                if (controller.isFeedLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.feedError != null &&
                    controller.nearMe.isEmpty &&
                    controller.popular.isEmpty &&
                    controller.recent.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: MyText(
                      text: controller.feedError!,
                      size: 13,
                      color: Colors.red,
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  if (controller.nearMe.isNotEmpty) ...[
                    _buildHorizontalSection(
                      title: 'Near Me',
                      items: controller.nearMe,
                    ),
                    const Gap(20),
                  ],
                  if (controller.popular.isNotEmpty) ...[
                    _buildHorizontalSection(
                      title: 'Popular',
                      items: controller.popular,
                    ),
                    const Gap(20),
                  ],
                  if (controller.recent.isNotEmpty)
                    _buildHorizontalSection(
                      title: 'Recently Added',
                      items: controller.recent,
                    ),
                ],
              ],
              const Gap(100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BrowseItemsController controller) {
    if (controller.isLoadingInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorMessage != null && controller.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: MyText(
          text: controller.errorMessage!,
          size: 13,
          color: Colors.red,
          textAlign: TextAlign.center,
        ),
      );
    }
    if (controller.items.isEmpty) {
      final label = controller.search?.isNotEmpty == true
          ? '"${controller.search}"'
          : controller.category?.isNotEmpty == true
              ? controller.category!
              : 'these filters';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: MyText(
            text: 'No items found for $label',
            size: 14,
            color: kSubText,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: controller.items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Bounce(
            onTap: () => Get.to(() => ItemDetailsScreen(itemId: item.id)),
            child: SneakerCard(
              itemId: item.id,
              title: item.title ?? 'Untitled',
              price:
                  '${item.currency ?? 'CAD'} ${item.dailyRate?.toStringAsFixed(2) ?? '0.00'}',
              imageUrl: item.thumbnailUrl.isNotEmpty
                  ? item.thumbnailUrl
                  : Assets.imagesShoes1,
              userName: item.ownerName,
              avatarUrl: (item.owner?.profilePhoto ?? '').isNotEmpty
                  ? item.owner!.profilePhoto!
                  : Assets.imagesChatAvatar,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<ItemModel> items,
  }) {
    return Column(
      children: [
        Bounce(
          onTap: () {
            Get.to(() => const HomeItemScreen());
          },
          child: Row(
            children: [
              MyText(text: title, weight: FontWeight.w600, size: 16),
              const Gap(10),
              const Expanded(child: Divider(thickness: 2)),
              const Gap(10),
              CommonImageView(imagePath: Assets.imagesNextSimple2, height: 20),
            ],
          ),
        ),
        const Gap(20),
        SizedBox(
          height: 310,
          child: items.isEmpty
              ? Center(
                  child: MyText(
                    text: 'No items found',
                    size: 14,
                    color: kSubText,
                    weight: FontWeight.w500,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Bounce(
                        onTap: () {
                          Get.to(() => ItemDetailsScreen(itemId: item.id));
                        },
                        child: SneakerCard(
                          itemId: item.id,
                          title: item.title ?? 'Untitled',
                          price:
                              '${item.currency ?? 'CAD'} ${item.dailyRate?.toStringAsFixed(2) ?? '0.00'}',
                          imageUrl: item.thumbnailUrl.isNotEmpty
                              ? item.thumbnailUrl
                              : Assets.imagesShoes1,
                          userName: item.ownerName,
                          avatarUrl: (item.owner?.profilePhoto ?? '').isNotEmpty
                              ? item.owner!.profilePhoto!
                              : Assets.imagesChatAvatar,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
