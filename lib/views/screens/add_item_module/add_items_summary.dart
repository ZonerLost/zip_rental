import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/items/add_item_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
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
  String? bookingType; // manual or instant
  String? rentalType; // delivery, pickup, or both
  String? scheduleType; // recurring or specific
  bool boosted = false;
  Map<String, dynamic>? itemDraft;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      bookingType = Get.arguments['bookingType'];
      rentalType = Get.arguments['rentalType'];
      scheduleType = Get.arguments['scheduleType'];
      boosted = Get.arguments['boosted'] ?? false;
      if (Get.arguments['itemDraft'] is Map<String, dynamic>) {
        itemDraft = Get.arguments['itemDraft'] as Map<String, dynamic>;
      }
    }
  }

  String get rentalTypeDisplay {
    if (rentalType == 'delivery') return 'Delivery Only';
    if (rentalType == 'pickup') return 'Pickup Only';
    if (rentalType == 'both') return 'Delivery & Pickup';
    return 'Pickup Only';
  }

  String get bookingTypeDisplay {
    if (bookingType == 'instant') {
      return 'Request to book (instant approval)';
    }
    return 'Request to book (manual approval)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GetBuilder<AddItemController>(
        init: Get.isRegistered<AddItemController>()
            ? Get.find<AddItemController>()
            : Get.put(AddItemController()),
        builder: (addItemController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyButton(
                onTap: () async {
                  final didCreate = await addItemController.createItemFromDraft(
                    itemDraft ?? const <String, dynamic>{},
                  );
                  if (!didCreate) {
                    return;
                  }
                  if (!mounted) {
                    return;
                  }
                  Get.snackbar('Success', 'Item added successfully.');
                  Get.offAll(() => const BottomNavBar(initialIndex: 3));
                },
                buttonText: addItemController.isSubmitting
                    ? 'Adding...'
                    : 'Add Item',
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
                    MyText(text: "Summary", size: 18, weight: FontWeight.w600),
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
                    Bounce(
                      onTap: () {},
                      child: Row(
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
                      final photos =
                          (itemDraft?['photos'] as List?) ?? const <dynamic>[];
                      if (photos.isNotEmpty && index < photos.length) {
                        final photoEntry = photos[index];
                        final filePath = photoEntry is File
                            ? photoEntry.path
                            : photoEntry.toString();
                        return CommonImageView(
                          height: 60,
                          width: 80,
                          radius: 12,
                          file: filePath.isNotEmpty ? File(filePath) : null,
                          imagePath: filePath.isEmpty
                              ? Assets.imagesShoes1
                              : null,
                          fit: BoxFit.cover,
                        );
                      }
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
                      text: (itemDraft?['title'] ?? 'Nike Jordan 6').toString(),
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
                      text: (itemDraft?['category'] ?? 'Footwear').toString(),
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
                      text: (itemDraft?['condition'] ?? 'Used, good condition')
                          .toString(),
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
                      text: rentalTypeDisplay,
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
                          text:
                              '\$${(itemDraft?['dailyRate'] ?? '45.00').toString()} ',
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
                if (rentalType == 'delivery' || rentalType == 'both') ...[
                  Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(text: 'Delivery Fees', size: 14, color: kSubText),
                      MyText(
                        text: '\$10.00',
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(text: 'Description', size: 14, color: kSubText),
                    MyText(
                      text:
                          (itemDraft?['description'] ??
                                  'Lorem upsum dlor isem teiyr')
                              .toString(),
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
                Expanded(
                  child: Column(
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
                ),
                Bounce(
                  onTap: () {},
                  child: Row(
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
                ),
              ],
            ),
          ),
          Gap(16),

          // Booking Type Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: MyText(
              text: bookingTypeDisplay,
              size: 16,
              weight: FontWeight.w600,
              color: kBlack,
            ),
          ),
          Gap(16),

          // Boost Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: 'Boost add',
                  size: 16,
                  weight: FontWeight.w600,
                  color: kBlack,
                ),
                MyText(
                  text: boosted ? '\$9.99' : '0\$',
                  size: 16,
                  weight: FontWeight.w600,
                  color: kBlack,
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
