// ignore_for_file: non_constant_identifier_names

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/double_white_contianers.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

void LogoutBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: 500,
          mainColor: kWhite3,
          topColor: kWhite,
          handleHeight: 14,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(20),
              CommonImageView(imagePath: Assets.imagesLogout, height: 150),
              const Gap(42),
              const MyText(
                textAlign: TextAlign.center,
                text: "Logout?",
                size: 24,
                weight: FontWeight.w700,
                color: Colors.black,
              ),
              const Gap(10),
              const MyText(
                text: "Are you sure want to logout from this app?",
                size: 16,
                textAlign: TextAlign.center,

                color: kSubText2,
                weight: FontWeight.w400,
              ),
              const Gap(40),

              MyButton(
                onTap: () {
                  Get.offAll(() => LoginScreen());
                },
                buttonText: "Yes, Logout",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        );
      },
    ),
  );
}

void BlockBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: 500,
          mainColor: kWhite3,
          topColor: kWhite,
          handleHeight: 14,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(20),
              CommonImageView(imagePath: Assets.imagesSucess, height: 150),
              const Gap(42),
              const MyText(
                textAlign: TextAlign.center,
                text: "Block User ",
                size: 24,
                weight: FontWeight.w700,
                color: Colors.black,
              ),
              const Gap(10),
              const MyText(
                text: "Are you sure want to block this user?",
                size: 16,
                textAlign: TextAlign.center,

                color: kSubText2,
                weight: FontWeight.w400,
              ),
              const Gap(40),

              MyButton(
                onTap: () {
                  Get.back();
                },
                buttonText: "Yes, Block",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        );
      },
    ),
  );
}

void ReportUserBottomSheet(BuildContext context) {
  // Keep track of selected reason
  String? selectedReason;

  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: 560, // enough space for all items
          mainColor: kWhite3,
          topColor: kWhite,
          handleHeight: 14,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Gap(20),
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, size: 18, color: Colors.black),
                        Gap(6),
                        MyText(
                          text: 'Back',
                          size: 16,
                          weight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(20),

              // ───── Title ─────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    MyText(
                      text: 'Report User',
                      size: 24,
                      weight: FontWeight.w700,
                      color: Colors.black,
                    ),

                    const Gap(12),

                    // ───── Subtitle ─────
                    MyText(
                      text:
                          'Please select the reasons so we can take the legal actions against the user.',
                      size: 15,
                      color: kSubText2,
                      textAlign: TextAlign.center,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // ───── Reason Chips ─────
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _reasonChip(
                    label: 'Fake Profile / Catfishing',
                    isSelected: selectedReason == 'Fake Profile / Catfishing',
                    onTap: () => setState(
                      () => selectedReason = 'Fake Profile / Catfishing',
                    ),
                  ),
                  _reasonChip(
                    label: 'Spam or Scamming',
                    isSelected: selectedReason == 'Spam or Scamming',
                    onTap: () =>
                        setState(() => selectedReason = 'Spam or Scamming'),
                    backgroundColor: kPrimaryColor.withOpacity(0.2),
                    textColor: kPrimaryColor,
                  ),
                  _reasonChip(
                    label: 'Inappropriate Photos or Content',
                    isSelected:
                        selectedReason == 'Inappropriate Photos or Content',
                    onTap: () => setState(
                      () => selectedReason = 'Inappropriate Photos or Content',
                    ),
                    backgroundColor: kPrimaryColor.withOpacity(0.2),
                    textColor: kPrimaryColor,
                  ),
                  _reasonChip(
                    label: 'Impersonation',
                    isSelected: selectedReason == 'Impersonation',
                    onTap: () =>
                        setState(() => selectedReason = 'Impersonation'),
                  ),
                  _reasonChip(
                    label: 'Underage User',
                    isSelected: selectedReason == 'Underage User',
                    onTap: () =>
                        setState(() => selectedReason = 'Underage User'),
                  ),
                  _reasonChip(
                    label: 'Hate Speech',
                    isSelected: selectedReason == 'Hate Speech',
                    onTap: () => setState(() => selectedReason = 'Hate Speech'),
                    backgroundColor: kPrimaryColor.withOpacity(0.2),
                    textColor: kPrimaryColor,
                  ),
                  _reasonChip(
                    label: 'Others',
                    isSelected: selectedReason == 'Others',
                    onTap: () => setState(() => selectedReason = 'Others'),
                  ),
                ],
              ),

              const Gap(40),

              // ───── Confirm Button ─────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MyButton(
                  onTap: () {},
                  buttonText: 'Confirm',
                  fontColor: Colors.white,
                  backgroundColor: kPrimaryColor,
                  height: 56,
                  radius: 30,
                  fontSize: 17,
                  hasgrad: false,
                  // optional: disable styling
                ),
              ),

              const Gap(30),
            ],
          ),
        );
      },
    ),
  );
}

Widget _reasonChip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
  Color? backgroundColor,
  Color? textColor,
}) {
  return Bounce(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (backgroundColor ?? kPrimaryColor.withOpacity(0.2))
            : (backgroundColor ?? kWhite),
        borderRadius: BorderRadius.circular(12),
      ),
      child: MyText(
        text: label,
        size: 14,
        weight: FontWeight.w500,
        color: isSelected
            ? (textColor ?? kPrimaryColor)
            : (textColor ?? Colors.black87),
      ),
    ),
  );
}

void showReviewRatingBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    DoubleWhiteContainers(
      height: 800,
      mainColor: kbackground,
      topColor: kWhite,
      handleHeight: 14,
      borderRadius: BorderRadius.circular(24),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(40),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesInfoCircle,
                        height: 20,
                      ),
                      Gap(8),
                      Expanded(
                        child: MyText(
                          text:
                              'Your rating will remain private until both parties have submitted their feedback.',
                          size: 13,
                          color: kPrimaryColor,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(24),

                // Upload Product Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesGallery,
                          height: 50,
                        ),
                        Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: 'Upload Product Images',
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                            Gap(2),
                            MyText(
                              text: 'Multiple images allowed',
                              size: 12,
                              color: kSubText,
                            ),
                          ],
                        ),
                      ],
                    ),
                    MyButton(
                      onTap: () {},
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      radius: 12,
                      width: 150,
                      height: 56,
                      buttonText: "Upload",
                      fontColor: kPrimaryColor,
                      backgroundColor: kPrimaryColor.withOpacity(0.2),
                      hasgrad: false,
                    ),
                  ],
                ),
                Gap(24),

                MyTextField(
                  label: "Describe your experience",
                  labelSize: 12,
                  labelColor: kSubText,
                  hint: "Lorem ipsum dolor ist amet",
                  maxLines: 5,
                  backgroundColor: kWhite,
                  hintColor: kBlack,
                  radius: 12,
                ),

                Spacer(),
                MyButton(
                  onTap: () {
                    Get.back();
                    // Show success bottom sheet
                    Future.delayed(Duration(milliseconds: 300), () {
                      showRequestAcceptedBottomSheet(Get.context!);
                    });
                  },
                  buttonText: "Submit",
                  fontColor: Colors.white,
                  height: 56,
                  radius: 28,
                  hasgrad: false,
                  fontSize: 17,
                ),
                Gap(20),
              ],
            ),
          );
        },
      ),
    ),
  );
}

// BOTTOM SHEET 2: Request Accepted
void showRequestAcceptedBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    DoubleWhiteContainers(
      height: 600,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 24, top: 48, left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonImageView(imagePath: Assets.imagesSucess, height: 150),
              Gap(32),

              // Title
              MyText(
                text: "Request Accepted!",
                size: 26,
                weight: FontWeight.w700,
                color: Colors.black,
                textAlign: TextAlign.center,
              ),
              Gap(16),

              // Subtitle
              MyText(
                text:
                    "You have successfully accepted the offer from Mike hesson. Amazing you helped save 5kg CO2 to someone else",
                size: 15,
                color: kSubText2,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              Gap(32),

              // Done Button
              MyButton(
                onTap: () {
                  Get.back();
                },
                buttonText: "Done",
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
    ),
  );
}
