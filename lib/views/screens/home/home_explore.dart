import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/home/home_widgets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/double_white_contianers.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen> {
  final List<Map<String, dynamic>> sneakers = const [
    {
      "title": "Nike Jordan’s 3310",
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
      body: Column(
        children: [
          const Gap(50),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Bounce(
                      onTap: () {
                        Get.back();
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 50,
                      ),
                    ),
                    MyText(
                      text: "Explore on Map",
                      size: 16,
                      color: kBlack,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
                const Gap(10),
                MyTextField(
                  marginBottom: 0,
                  backgroundColor: kWhite,
                  hint: "Brook |",
                  hintColor: kSubText2,
                  isObSecure: false,
                  radius: 25,
                  hintsize: 12,
                  hintWeight: FontWeight.w400,
                  suffix: CommonImageView(
                    imagePath: Assets.imagesMynauiSearch,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                /// MAP FULL WIDTH
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                    child: CommonImageView(
                      imagePath: Assets.imagesMap,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                /// WHITE BOTTOM SHEET
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: DoubleWhiteContainers(
                    height: 430,
                    mainColor: kWhite3,
                    topColor: kWhite,
                    handleHeight: 14,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),

                    /// HORIZONTAL LIST OF CARDS
                    child: SizedBox(
                      height: 310,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: sneakers.length,
                        itemBuilder: (context, index) {
                          final sneaker = sneakers[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SneakerCard(
                              title: sneaker["title"],
                              price: sneaker["price"],
                              imageUrl: sneaker["image"],
                              userName: sneaker["user"],
                              avatarUrl: sneaker["avatar"],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
