import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/home/home_explore.dart';
import 'package:zip_peer/views/screens/home/home_item.dart';
import 'package:zip_peer/views/screens/home/home_widgets.dart'; // Assuming FilterChipWidget & HeaderRow2 are here
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
  final List<String> tabs = [
    "Footwear",
    "Electronics",
    "Sportwear",
    "Home Appliances",
  ];

  int _selectedIndex = 0;
  bool _isMapView = false;

  final List<Map<String, dynamic>> sneakers = const [
    {
      "title": "Nike Jordan's 3310",
      "price": "€49.99",
      "image": Assets.imagesShoes1,
      "user": "Chris T.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Air Max 2090",
      "price": "€59.99",
      "image": Assets.imagesShoes2,

      "user": "Alex K.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "React Element 87",
      "price": "€69.99",
      "image": Assets.imagesShoes3,
      "user": "Sarah M.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Blazer Mid '77",
      "price": "€44.99",
      "image": Assets.imagesShoes4,
      "user": "Mike D.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Nike Jordan's 3310",
      "price": "€49.99",
      "image": Assets.imagesShoes1,
      "user": "Chris T.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Air Max 2090",
      "price": "€59.99",
      "image": Assets.imagesShoes2,

      "user": "Alex K.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "React Element 87",
      "price": "€69.99",
      "image": Assets.imagesShoes3,
      "user": "Sarah M.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Blazer Mid '77",
      "price": "€44.99",
      "image": Assets.imagesShoes4,
      "user": "Mike D.",
      "avatar": Assets.imagesChatAvatar,
    },
  ];

  final List<Map<String, dynamic>> recents = const [
    {
      "title": "Nike Jordan's 3310",
      "price": "€49.99",
      "image": Assets.imagesShoes1,
      "user": "Chris T.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Air Max 2090",
      "price": "€59.99",
      "image": Assets.imagesShoes2,

      "user": "Alex K.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "React Element 87",
      "price": "€69.99",
      "image": Assets.imagesShoes3,
      "user": "Sarah M.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Blazer Mid '77",
      "price": "€44.99",
      "image": Assets.imagesShoes4,
      "user": "Mike D.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Nike Jordan's 3310",
      "price": "€49.99",
      "image": Assets.imagesShoes1,
      "user": "Chris T.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Air Max 2090",
      "price": "€59.99",
      "image": Assets.imagesShoes2,

      "user": "Alex K.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "React Element 87",
      "price": "€69.99",
      "image": Assets.imagesShoes3,
      "user": "Sarah M.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Blazer Mid '77",
      "price": "€44.99",
      "image": Assets.imagesShoes4,
      "user": "Mike D.",
      "avatar": Assets.imagesChatAvatar,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
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
                    text: "Welcome Back!",
                    size: 14,
                    color: kSubText,
                    weight: FontWeight.w500,
                  ),
                  MyText(
                    text: "Christopher Henry",
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
              Row(
                children: [
                  Bounce(
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
            hint: "What tools are you looking for ...",
            hintColor: kSubText2,
            isObSecure: false,
            radius: 25,
            hintsize: 12,
            hintWeight: FontWeight.w400,
            prefix: CommonImageView(
              imagePath: Assets.imagesMynauiSearch,
              height: 24,
            ),
            suffix: Bounce(
              onTap: () {
                setState(() {
                  Get.to(() => const HomeExploreScreen());
                });
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
                  text: "Explore on Map",
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

          Bounce(
            onTap: () {
              Get.to(() => const HomeItemScreen());
            },
            child: Row(
              children: [
                MyText(
                  text: "Recently added near you",
                  weight: FontWeight.w600,
                  size: 16,
                ),
                const Gap(10),
                const Expanded(child: Divider(thickness: 2)),
                const Gap(10),
                CommonImageView(
                  imagePath: Assets.imagesNextSimple2,
                  height: 20,
                ),
              ],
            ),
          ),
          const Gap(20),
          SizedBox(
            height: 330,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sneakers.length,
              itemBuilder: (context, index) {
                final sneaker = sneakers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Bounce(
                    onTap: () {
                      Get.to(() => const ItemDetailsScreen());
                    },
                    child: SneakerCard(
                      title: sneaker["title"],
                      price: sneaker["price"],
                      imageUrl: sneaker["image"],
                      userName: sneaker["user"],
                      avatarUrl: sneaker["avatar"],
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(20),

          Bounce(
            onTap: () {
              Get.to(() => const HomeItemScreen());
            },
            child: Row(
              children: [
                MyText(
                  text: "Popular near you ",

                  weight: FontWeight.w600,
                  size: 16,
                ),
                const Gap(10),
                const Expanded(child: Divider(thickness: 2)),
                const Gap(10),
                CommonImageView(
                  imagePath: Assets.imagesNextSimple2,
                  height: 20,
                ),
              ],
            ),
          ),
          const Gap(20),
          SizedBox(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recents.length,
              itemBuilder: (context, index) {
                final recentItem = recents[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Bounce(
                    onTap: () {
                      Get.to(() => const ItemDetailsScreen());
                    },
                    child: SneakerCard(
                      title: recentItem["title"],
                      price: recentItem["price"],
                      imageUrl: recentItem["image"],
                      userName: recentItem["user"],
                      avatarUrl: recentItem["avatar"],
                    ),
                  ),
                );
              },
            ),
          ),

          Bounce(
            onTap: () {
              Get.to(() => const HomeItemScreen());
            },
            child: Row(
              children: [
                MyText(
                  text: "Recently Viewed",
                  weight: FontWeight.w600,
                  size: 16,
                ),
                const Gap(10),
                const Expanded(child: Divider(thickness: 2)),
                const Gap(10),
                CommonImageView(
                  imagePath: Assets.imagesNextSimple2,
                  height: 20,
                ),
              ],
            ),
          ),
          const Gap(20),
          SizedBox(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sneakers.length,
              itemBuilder: (context, index) {
                final sneaker = sneakers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Bounce(
                    onTap: () {
                      Get.to(() => const ItemDetailsScreen());
                    },
                    child: SneakerCard(
                      title: sneaker["title"],
                      price: sneaker["price"],
                      imageUrl: sneaker["image"],
                      userName: sneaker["user"],
                      avatarUrl: sneaker["avatar"],
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(20),

          Bounce(
            onTap: () {
              Get.to(() => const HomeItemScreen());
            },
            child: Row(
              children: [
                MyText(text: "Popular ", weight: FontWeight.w600, size: 16),
                const Gap(10),
                const Expanded(child: Divider(thickness: 2)),
                const Gap(10),
                CommonImageView(
                  imagePath: Assets.imagesNextSimple2,
                  height: 20,
                ),
              ],
            ),
          ),
          const Gap(20),
          SizedBox(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sneakers.length,
              itemBuilder: (context, index) {
                final sneaker = sneakers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Bounce(
                    onTap: () {
                      Get.to(() => const ItemDetailsScreen());
                    },
                    child: SneakerCard(
                      title: sneaker["title"],
                      price: sneaker["price"],
                      imageUrl: sneaker["image"],
                      userName: sneaker["user"],
                      avatarUrl: sneaker["avatar"],
                    ),
                  ),
                );
              },
            ),
          ),

          const Gap(100),
        ],
      ),
    );
  }
}
