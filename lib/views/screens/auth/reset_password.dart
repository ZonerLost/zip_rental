// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/auth/reset_password_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FocusNode otpFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    otpFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResetPasswordController>(
      init: ResetPasswordController(),
      builder: (controller) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: kbackground,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyButton(
                    onTap: controller.submit,
                    fontSize: 18,
                    radius: 30,
                    height: 60,
                    buttonText: "Confirm",
                    backgroundColor: controller.isButtonActive
                        ? kPrimaryColor
                        : kPrimaryColor2,
                    fontColor: Colors.white,
                    hasgrad: false,
                  ),
                  Gap(40),
                ],
              ),
            ),
            body: ListView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Gap(50),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Bounce(
                    onTap: Get.back,
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                ),
                Gap(20),
                MyText(
                  text: "Reset Password",
                  size: 24,
                  color: kFontText,
                  weight: FontWeight.w700,
                ),
                Gap(8),
                MyText(
                  text: "Please create your new password. Do not share your password with anyone.",
                  size: 14,
                  color: kSubText2,
                  weight: FontWeight.w500,
                ),
                Gap(32),
                MyTextField(
                  hint: "OTP Code",
                  hintColor: kBlack,
                  controller: controller.otpController,
                  focusNode: otpFocus,
                  radius: 24,
                  keyboardType: TextInputType.number,
                  suffix: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: controller.otpController.text.trim().length == 6
                        ? Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        : CommonImageView(
                            imagePath: Assets.imagesPasswordKey,
                            height: 20,
                            width: 20,
                          ),
                  ),
                  onChanged: controller.onOtpChanged,
                ),
                MyTextField(
                  hint: "Create new password",
                  hintColor: kBlack,
                  controller: controller.passwordController,
                  isObSecure: true,
                  showObscureToggle: true,
                  focusNode: passwordFocus,
                  radius: 24,
                  suffix: controller.passwordController.text.trim().isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: controller.isPasswordStrong
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                )
                              : const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                        )
                      : null,
                  onChanged: controller.onPasswordChanged,
                ),
                MyTextField(
                  hint: "Confirm new password",
                  hintColor: kBlack,
                  controller: controller.confirmPasswordController,
                  isObSecure: true,
                  showObscureToggle: true,
                  focusNode: confirmPasswordFocus,
                  radius: 24,
                  suffix: controller.confirmPasswordController.text.trim().isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: controller.isPasswordMatch
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                )
                              : const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                        )
                      : null,
                  onChanged: controller.onConfirmPasswordChanged,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
