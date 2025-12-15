import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zip_peer/constants/app_colors.dart';
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
    return Row(
      spacing: 10,
      children: [
        Bounce(
          onTap: () {
            showFiltersBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              spacing: 10,
              children: [
                CommonImageView(
                  imagePath: Assets.imagesCategoryFootwear,
                  height: 16,
                ),
                MyText(
                  text: "Footwear",
                  size: 14,
                  weight: FontWeight.w400,
                  color: kBlack,
                ),
              ],
            ),
          ),
        ),

        Bounce(
          onTap: () {
            showFiltersBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              spacing: 10,
              children: [
                CommonImageView(imagePath: Assets.imagesDiscover, height: 16),
                MyText(
                  text: "Boorklyn, USA",
                  size: 14,
                  weight: FontWeight.w400,
                  color: kBlack,
                ),
              ],
            ),
          ),
        ),

        Bounce(
          onTap: () {
            showFiltersBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              spacing: 10,
              children: [
                CommonImageView(imagePath: Assets.imagesDiscover, height: 16),
                MyText(
                  text: "10 km",
                  size: 14,
                  weight: FontWeight.w400,
                  color: kBlack,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SneakerCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String userName;
  final String avatarUrl;

  const SneakerCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              // Top image section
              CommonImageView(
                imagePath: imageUrl,
                fit: BoxFit.contain,
                height: 280,
              ),

              // Heart icon
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
                        CommonImageView(imagePath: avatarUrl, height: 30),

                        const SizedBox(width: 12),
                        Column(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: userName,

                              size: 14,
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
                          width: i == 0 ? 25 : 8,
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
        ),
        Gap(10),
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
    );
  }
}
