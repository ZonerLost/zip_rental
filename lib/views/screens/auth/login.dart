// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/auth/login_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode identifierFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    identifierFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return GetBuilder<LoginController>(
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            identifierFocus.unfocus();
            passwordFocus.unfocus();
          },
          child: Scaffold(
            backgroundColor: kbackground,
            body: AnimatedListView(
              padding: EdgeInsets.all(20),
              children: [
                Gap(100),
                MyText(
                  text: "Login to your account",
                  size: 28,
                  color: kFontText,
                  weight: FontWeight.w700,
                ),
                const Gap(8),
                MyText(
                  text: "Please enter the credentials to get started.",
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
                  hint: "Password",
                  hintColor: kBlack,
                  controller: controller.passwordController,
                  isObSecure: true,
                  showObscureToggle: true,
                  focusNode: passwordFocus,
                  radius: 25,
                  onChanged: controller.onPasswordChanged,
                ),
                const Gap(12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Bounce(
                    onTap: controller.openForgotPassword,
                    child: MyText(
                      text: "Forgot Password?",
                      size: 16,
                      color: kPrimaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const Gap(120),
                Center(
                  child: Bounce(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesFaceRecognition,
                          height: 24,
                        ),
                        const Gap(8),
                        MyText(
                          text: "Use Face ID",
                          size: 16,
                          color: kBlack,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(24),
                MyButton(
                  onTap: controller.submit,
                  fontSize: 18,
                  radius: 30,
                  height: 56,
                  buttonText: "Continue",
                  fontColor: Colors.white,
                  backgroundColor: controller.isButtonActive
                      ? kPrimaryColor
                      : kPrimaryColor2,
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
                        text: "Don't have an Account?",
                        size: 16,
                        color: kSubText2,
                        weight: FontWeight.w600,
                      ),
                      const Gap(6),
                      Bounce(
                        onTap: controller.openSignup,
                        child: MyText(
                          text: "Register",
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
          ),
        );
      },
    );
  }
}
