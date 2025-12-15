import 'package:bounce/bounce.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_animated_row.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class DialogHelper {
  static void ChangePasswordDialog(BuildContext context) {
    Get.dialog(
      AnimatedColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: AnimatedColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MyText(
                      text: "Change Password",
                      size: 22,
                      color: kFontText,
                      weight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(
                        imagePath: Assets.imagesClose,
                        height: 32,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                const MyText(
                  text:
                      "Enter your current password first in order to change your password",

                  size: 16,
                  color: kFontText7,
                  paddingBottom: 24,
                  weight: FontWeight.w500,
                ),
                Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          MyText(
                            text: "Current Password",
                            size: 16,
                            color: kFontText,
                            weight: FontWeight.w700,
                          ),
                          CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 16,
                          ),
                        ],
                      ),
                      Gap(12),
                      MyTextField(
                        hint: "**********",
                        hintsize: 14,
                        hintWeight: FontWeight.w600,
                        hintColor: kFontText5,
                        marginBottom: 12,
                        prefix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 24,
                          ),
                        ),
                        suffix: Bounce(
                          onTap: () {},
                          child: CommonImageView(
                            imagePath: Assets.imagesEye, // Change icon
                            height: 24,
                          ),
                        ),
                      ),

                      Row(
                        spacing: 6,
                        children: [
                          MyText(
                            text: "New Password",
                            size: 16,
                            color: kFontText,
                            weight: FontWeight.w700,
                          ),
                          CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 16,
                          ),
                        ],
                      ),
                      Gap(12),
                      MyTextField(
                        hint: "**********",
                        hintsize: 14,
                        hintWeight: FontWeight.w600,
                        hintColor: kFontText5,
                        marginBottom: 12,
                        prefix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 24,
                          ),
                        ),
                        suffix: Bounce(
                          onTap: () {},
                          child: CommonImageView(
                            imagePath: Assets.imagesEye, // Change icon
                            height: 24,
                          ),
                        ),
                      ),
                      Row(
                        spacing: 6,
                        children: [
                          MyText(
                            text: "Confirm Password",
                            size: 16,
                            color: kFontText,
                            weight: FontWeight.w700,
                          ),
                          CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 16,
                          ),
                        ],
                      ),
                      Gap(12),
                      MyTextField(
                        hint: "**********",
                        hintsize: 14,
                        hintWeight: FontWeight.w600,
                        hintColor: kFontText5,
                        marginBottom: 24,
                        prefix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 24,
                          ),
                        ),
                        suffix: Bounce(
                          onTap: () {},
                          child: CommonImageView(
                            imagePath: Assets.imagesEye, // Change icon
                            height: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                MyButton(
                  backgroundColor: kPrimaryColor,
                  buttonText: 'Change Password',
                  onTap: () {
                    Get.back();
                  },
                ),
                Gap(15),
                MyButton(
                  onTap: () {
                    Get.back();
                  },
                  radius: 12,
                  backgroundColor: kbackground,
                  outlineColor: kBorderColor3,
                  fontColor: kFontText,
                  buttonText: "Cancel",
                  hasgrad: false,
                ),
                Gap(15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void LogoutDialog(BuildContext context) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AnimatedColumn(
            animationDuration: 200,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: AppSizes.DEFAULT,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: AnimatedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesLogout,
                          height: 40,
                        ),
                        Bounce(
                          onTap: () => Get.back(),
                          child: CommonImageView(
                            imagePath: Assets.imagesClose,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const MyText(
                      text: "Confirm Logout?",
                      size: 24,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                    const MyText(
                      text:
                          "You’re about to sign out of our app. Drafts are auto-saved and can be restored when you log back in.",
                      size: 16,
                      color: kFontText7,
                      paddingBottom: 24,

                      weight: FontWeight.w500,
                    ),
                    MyButton(
                      fontWeight: FontWeight.w600,
                      backgroundColor: kPrimaryColor,
                      buttonText: 'Confirm, Logout',
                      fontColor: kWhite,
                      onTap: () {
                        Get.offAll(() => const LoginScreen());
                      },
                    ),
                    Gap(10),
                    MyButton(
                      onTap: () {
                        Get.back();
                      },
                      radius: 12,
                      backgroundColor: kWhite,
                      outlineColor: kBorderColor3,
                      fontColor: kFontText,
                      buttonText: "Cancel",
                      hasgrad: false,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false, // Prevent dismissing while loading
    );
  }

  static void CacheDialog(BuildContext context) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AnimatedColumn(
            animationDuration: 200,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: AppSizes.DEFAULT,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: AnimatedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesPasswordKey,
                          height: 40,
                        ),
                        Bounce(
                          onTap: () => Get.back(),
                          child: CommonImageView(
                            imagePath: Assets.imagesClose,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const MyText(
                      text: "Clear Cache & Offline Data",
                      size: 24,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                    const MyText(
                      text:
                          "This removes stored searches and diagrams. You can still use the app, but offline access will be unavailable.",
                      size: 16,
                      color: kFontText7,
                      paddingBottom: 24,

                      weight: FontWeight.w500,
                    ),
                    MyButton(
                      fontWeight: FontWeight.w600,
                      backgroundColor: kPrimaryColor,
                      buttonText: 'Clear Data',
                      fontColor: kWhite,
                      onTap: () {
                        Get.back();
                      },
                    ),
                    Gap(10),
                    MyButton(
                      onTap: () {
                        Get.back();
                      },
                      radius: 12,
                      backgroundColor: kWhite,
                      outlineColor: kBorderColor3,
                      fontColor: kFontText,
                      buttonText: "Cancel",
                      hasgrad: false,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false, // Prevent dismissing while loading
    );
  }

  static void FeedbackSentDialog(BuildContext context) {
    Get.dialog(
      Center(
        child: Container(
          margin: AppSizes.DEFAULT,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kWhite,
            border: Border.all(color: kBorderColor3),
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: kBlack.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(20),
              const MyText(
                text: "Thank you. Your feedback has been sent.",
                color: kFontText,
                size: 16,
                weight: FontWeight.w600,
              ),
              Gap(20),
            ],
          ),
        ),
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 200),
    );

    // Auto close after 2.5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }
}
