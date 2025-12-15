import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class HomeItemScreen extends StatefulWidget {
  const HomeItemScreen({super.key});

  @override
  State<HomeItemScreen> createState() => _HomeItemScreenState();
}

class _HomeItemScreenState extends State<HomeItemScreen> {
  final List<Map<String, dynamic>> sneakers = const [
    {
      "title": "Nike Jordan’s 3310",
      "price": "€49.99",
      "image": Assets.imagesShoes1,
      "user": "Chris T.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Nike Air P90 45’ Size",
      "price": "€49.99",
      "image": Assets.imagesShoes2,
      "user": "Mike H.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Nike Red Special Edition",
      "price": "€49.99",
      "image": Assets.imagesShoes3,
      "user": "Josh B.",
      "avatar": Assets.imagesChatAvatar,
    },
    {
      "title": "Nike Pro 2 Limited",
      "price": "€49.99",
      "image": Assets.imagesShoes4,
      "user": "Melisa P.",
      "avatar": Assets.imagesChatAvatar,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
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
                text: "Footwear",
                size: 20,
                color: kBlack,
                weight: FontWeight.w600,
              ),
            ],
          ),

          const Gap(25),

          /// RESULTS TEXT
          Row(
            children: [
              MyText(
                text: "8 Results found for ",
                size: 14,
                color: kSubText,
                weight: FontWeight.w500,
              ),
              MyText(
                text: "Nike Jordans",
                size: 14,
                color: kBlack,
                weight: FontWeight.w600,
              ),
            ],
          ),

          const Gap(20),

          /// 2-COLUMN GRID CARDS
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sneakers.length,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.56,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
            ),
            itemBuilder: (context, index) {
              final item = sneakers[index];
              return _SneakerGridCard(
                title: item["title"],
                price: item["price"],
                image: item["image"],
                user: item["user"],
                avatar: item["avatar"],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SneakerGridCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  final String user;
  final String avatar;

  const _SneakerGridCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.user,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// IMAGE + HEART BUTTON + USER ROW
        Stack(
          children: [
            /// PRODUCT IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CommonImageView(
                imagePath: image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            /// HEART ICON
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesChatAvatar,
                        height: 25,
                      ),

                      const SizedBox(width: 12),
                      Column(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: user,

                            size: 12,
                            color: kBlack,
                            weight: FontWeight.w500,
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
                    ],
                  ),
                  Row(
                    children: List.generate(3, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == 0 ? 20 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == 0 ? kWhite : kWhite,
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

        /// TITLE
        MyText(text: title, size: 14, color: kBlack, weight: FontWeight.w600),

        const Gap(4),

        /// PRICE + MONTH
        Row(
          children: [
            MyText(
              text: price,
              size: 14,
              color: kBlack,
              weight: FontWeight.w600,
            ),
            MyText(
              text: " /month",
              size: 12,
              color: kSubText,
              weight: FontWeight.w400,
            ),
          ],
        ),
      ],
    );
  }
}
