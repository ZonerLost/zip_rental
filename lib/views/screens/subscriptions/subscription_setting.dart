// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final double progressValue = 0.6;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(50),
            Row(
              children: [
                Bounce(
                  onTap: () => Get.back(),
                  child: CommonImageView(
                    imagePath: Assets.imagesBack,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 10),
                MyText(
                  text: "Subscription",
                  size: 16,
                  color: kBlack,
                  weight: FontWeight.w600,
                ),
              ],
            ),
            const Gap(30),
            // Core Plan Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesDoubleTick,
                        height: 44,
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: "Basic Plan",
                            size: 18,
                            weight: FontWeight.w600,
                            color: kBlack,
                          ),
                          MyText(
                            text: "Your free trial will expire in 2 days.",
                            size: 12,
                            weight: FontWeight.w600,
                            color: kSubText2,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: MyText(
                          text: "Active",
                          size: 12,
                          color: const Color(0xFF00A86B),
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: kBlack50,
                      color: kPrimaryColor,
                      minHeight: 8,
                    ),
                  ),
                  const Gap(10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: "Subscribed: May 23, 2025",
                        size: 14,
                        color: kSubText2,
                      ),
                      MyText(text: "1/3 days used", size: 14, color: kSubText2),
                    ],
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: MyButton(
                          buttonText: "Cancel",
                          onTap: () {
                            // Handle cancel
                          },
                          hasgrad: false,
                          backgroundColor: kbackground,
                          fontColor: kSubText2,
                          radius: 25,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: MyButton(
                          buttonText: "Auto Renewal On",
                          onTap: () {},
                          hasgrad: false,

                          backgroundColor: kPrimaryColor.withOpacity(0.2),
                          fontColor: kPrimaryColor,
                          fontWeight: FontWeight.w500,
                          radius: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Gap(32),

            // Payment Methods Section
            MyText(
              text: "PAYMENT METHODS",
              size: 14,
              letterSpacing: 1,
              color: kBlack.withOpacity(0.6),
              weight: FontWeight.w500,
            ),
            const Gap(12),

            // Mastercard Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: "Mastercard ****56",
                          size: 18,
                          weight: FontWeight.w500,
                          color: kBlack,
                          paddingBottom: 5,
                        ),
                        MyText(
                          text: "Expiry date: 05/29",
                          size: 14,
                          weight: FontWeight.w500,
                          color: kBlack.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  Bounce(
                    onTap: () {
                      // Delete payment method
                    },
                    child: CommonImageView(
                      imagePath: Assets.imagesTrash,
                      height: 32,
                    ),
                  ),
                  const Gap(8),
                  Bounce(
                    onTap: () {
                      // Delete payment method
                    },
                    child: CommonImageView(
                      imagePath: Assets.imagesEditProfile,
                      height: 32,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Add New Payment Method Button
            MyButton(
              buttonText: "Add new payment method",
              onTap: () {
                cardInfoBottomSheet(context);
              },
              backgroundColor: kPrimaryColor,
              fontColor: kWhite,
              height: 60,
              radius: 28,
              fontSize: 16,
            ),
            Gap(50),
          ],
        ),
      ),
    );
  }
}
