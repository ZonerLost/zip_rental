import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class AddItemsSummaryScreen extends StatefulWidget {
  const AddItemsSummaryScreen({super.key});

  @override
  State<AddItemsSummaryScreen> createState() => _AddItemsSummaryScreenState();
}

class _AddItemsSummaryScreenState extends State<AddItemsSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              onTap: () {
                ItemAddedBottomSheet(context);
              },
              buttonText: "Add Item",
              fontColor: Colors.white,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 17,
            ),
            Gap(20),
          ],
        ),
      ),
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Gap(50),
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bounce(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    CommonImageView(imagePath: Assets.imagesBack, height: 40),
                    Gap(8),
                    MyText(
                      text: "Summary",
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(24),

          // Product Information Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: 'Product Information',
                      size: 14,
                      weight: FontWeight.w500,
                      color: kBlack,
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesEditProfile2,
                          height: 16,
                        ),
                        MyText(
                          text: 'Edit',
                          size: 14,
                          color: kPrimaryColor,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(20),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) => Gap(12),
                    itemBuilder: (context, index) {
                      return CommonImageView(
                        height: 60,
                        width: 80,
                        radius: 12,
                        imagePath: Assets.imagesShoes1,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Product Name', size: 14, color: kSubText),
                    MyText(
                      text: 'Mike Hesson',
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Category', size: 14, color: kSubText),
                    MyText(
                      text: 'Oct 20, 2001',
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Condition', size: 14, color: kSubText),
                    MyText(
                      text: 'St3 , Wilson road , Brooklyn',
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Rental Type', size: 14, color: kSubText),
                    MyText(
                      text: 'Pickup Only',
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Price', size: 14, color: kSubText),
                    Row(
                      children: [
                        MyText(
                          text: '\$45.00 ',
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                        MyText(
                          text: '/ Day',
                          size: 16,
                          color: kSubText,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Delivery Fees', size: 14, color: kSubText),
                    MyText(text: '\$10.00', size: 16, weight: FontWeight.w600),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Description', size: 14, color: kSubText),
                    MyText(
                      text: 'Lorem upsum dlor isem teiyr',
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(16),

          // Home Address Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      text: 'Home Address',
                      size: 16,
                      weight: FontWeight.w600,
                      color: kBlack,
                    ),

                    MyText(
                      text: 'St3 , Wilson road , Brooklyn, USA 10121',
                      size: 12,
                      color: kSubText,
                    ),
                  ],
                ),
                Row(
                  spacing: 6,

                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesEditProfile2,
                      height: 16,
                    ),
                    MyText(
                      text: 'Edit',
                      size: 14,
                      color: kPrimaryColor,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(16),

          // Availability Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: 'Availability',
                      size: 16,
                      weight: FontWeight.w600,
                      color: kBlack,
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesEditProfile2,
                          height: 16,
                        ),
                        MyText(
                          text: 'Edit',
                          size: 14,
                          color: kPrimaryColor,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Monday', size: 14, color: kSubText),
                    MyText(text: '06:00 PM - 05:00 PM', size: 16),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Wednesday', size: 14, color: kSubText),
                    MyText(text: '06:00 PM - 05:00 PM', size: 16),
                  ],
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Sunday', size: 14, color: kSubText),
                    MyText(text: '06:00 PM - 05:00 PM', size: 16),
                  ],
                ),
              ],
            ),
          ),
          Gap(100),
        ],
      ),
    );
  }
}
