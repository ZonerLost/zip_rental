import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class BoostScreen extends StatefulWidget {
  const BoostScreen({super.key});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyButton(
              onTap: () {
                ItemAddedBottomSheet(context);
              },
              buttonText: "Boost Ad",
              fontColor: Colors.white,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 17,
            ),
            Gap(20),
            MyButton(
              onTap: () {
                Get.off(() => BottomNavBar(initialIndex: 2));
              },
              buttonText: "Skip this step",
              fontColor: kPrimaryColor,
              backgroundColor: kWhite,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 17,
            ),
            Gap(20),
          ],
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                        text: "Boost Ad",
                        size: 18,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                MyText(text: "Step 4/4", size: 14, color: kSubText),
              ],
            ),
            Gap(20),

            Spacer(),
            Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesSpaceShip,
                      height: 150,
                    ),
                  ],
                ),
                MyText(
                  text: "Boost your ad for \$9.99",
                  size: 18,
                  weight: FontWeight.w600,
                ),
                MyText(
                  text:
                      "Get more views and better results by promoting your listing.",
                  size: 14,
                  color: kSubText,
                  textAlign: TextAlign.center,
                  weight: FontWeight.w500,
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
