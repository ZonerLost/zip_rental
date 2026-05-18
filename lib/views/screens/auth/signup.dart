// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/auth/signup_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode identifierFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    identifierFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(
      init: SignupController(),
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            firstNameFocus.unfocus();
            lastNameFocus.unfocus();
            identifierFocus.unfocus();
            passwordFocus.unfocus();
          },
          child: Scaffold(
            body: AnimatedListView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Bounce(
                          onTap: Get.back,
                          child: CommonImageView(
                            imagePath: Assets.imagesBack,
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                    Gap(40),
                    MyText(
                      text: "Create Account",
                      size: 28,
                      color: kFontText,
                      weight: FontWeight.w700,
                    ),
                    const Gap(8),
                    MyText(
                      text: "Please enter your information to register yourself.",
                      size: 14,
                      color: kSubText2,
                      weight: FontWeight.w500,
                    ),
                    const Gap(32),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: List.generate(controller.tabs.length, (index) {
                          final isSelected = controller.selectedTabIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectTab(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kPrimaryColor.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: MyText(
                                    text: controller.tabs[index],
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: isSelected
                                        ? kPrimaryColor
                                        : Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Gap(24),
                    MyTextField(
                      hint: "First Name",
                      hintColor: kBlack,
                      controller: controller.firstNameController,
                      focusNode: firstNameFocus,
                      radius: 25,
                      onChanged: controller.onFirstNameChanged,
                    ),
                    MyTextField(
                      hint: "Last Name",
                      hintColor: kBlack,
                      controller: controller.lastNameController,
                      focusNode: lastNameFocus,
                      radius: 25,
                      onChanged: controller.onLastNameChanged,
                    ),
                    MyTextField(
                      hint: controller.firstHint,
                      hintColor: kBlack,
                      controller: controller.identifierController,
                      focusNode: identifierFocus,
                      radius: 25,
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: controller.isEmailValid
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
                                imagePath: controller.firstIcon,
                                height: 24,
                              ),
                      ),
                      onChanged: controller.onIdentifierChanged,
                    ),
                    MyTextField(
                      hint: "Create Password",
                      hintColor: kBlack,
                      controller: controller.passwordController,
                      isObSecure: true,
                      showObscureToggle: true,
                      focusNode: passwordFocus,
                      radius: 25,
                      suffix: controller.passwordController.text.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12),
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
                    const Gap(120),
                    CustomCheckbox(
                      text: " Enable Face ID",
                      onChanged: controller.onFaceIdChanged,
                    ),
                    Gap(24),
                    MyButton(
                      onTap: controller.submit,
                      fontSize: 18,
                      radius: 30,
                      height: 56,
                      backgroundColor: controller.isButtonActive
                          ? kPrimaryColor
                          : kPrimaryColor2,
                      buttonText: "Continue",
                      fontColor: Colors.white,
                      hasgrad: false,
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: kDividerColor2)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MyText(
                            text: "or sign in",
                            size: 14,
                            color: kSubText2,
                          ),
                        ),
                        Expanded(child: Divider(color: kDividerColor2)),
                      ],
                    ),
                    const Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Bounce(
                          onTap: controller.continueWithGoogle,
                          child: CommonImageView(
                            imagePath: Assets.imagesGoogle,
                            height: 58,
                          ),
                        ),
                        const Gap(16),
                        Bounce(
                          onTap: controller.continueWithApple,
                          child: CommonImageView(
                            imagePath: Assets.imagesAppleButton,
                            height: 58,
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText(
                            text: "Already have an Account?",
                            size: 16,
                            color: kSubText2,
                            weight: FontWeight.w600,
                          ),
                          const Gap(6),
                          Bounce(
                            onTap: controller.openLogin,
                            child: MyText(
                              text: "Login",
                              size: 16,
                              color: kPrimaryColor,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(40),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
