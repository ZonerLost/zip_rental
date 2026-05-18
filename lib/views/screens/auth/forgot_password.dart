// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/auth/forgot_password_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FocusNode emailFocus = FocusNode();

  @override
  void dispose() {
    emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      init: ForgotPasswordController(),
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
                    onTap: controller.sendVerificationLink,
                    fontSize: 18,
                    radius: 30,
                    height: 60,
                    buttonText: "Send Verification Link",
                    backgroundColor: controller.isButtonActive
                        ? kPrimaryColor
                        : kPrimaryColor2,
                    fontColor: Colors.white,
                    hasgrad: false,
                  ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text: "Back to ",
                        size: 16,
                        color: kSubText2,
                        weight: FontWeight.w600,
                      ),
                      Bounce(
                        onTap: Get.back,
                        child: MyText(
                          text: "Login",
                          size: 16,
                          color: kPrimaryColor,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Gap(20),
                ],
              ),
            ),
            body: AnimatedListView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(60),
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
                      text: "Forgot Password",
                      size: 24,
                      color: kFontText,
                      weight: FontWeight.w700,
                    ),
                    Gap(8),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        children: [
                          TextSpan(
                            text: "Please enter the email address that starts with",
                            style: TextStyle(
                              color: kSubText2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: " k******@gmail.com",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(24),
                    MyTextField(
                      hint: "Email address",
                      hintColor: kBlack,
                      controller: controller.emailController,
                      alwaysShowLabel: true,
                      focusNode: emailFocus,
                      radius: 24,
                      suffix: Padding(
                        padding: const EdgeInsets.all(12.0),
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
                                  size: 18,
                                ),
                              )
                            : CommonImageView(
                                imagePath: Assets.imagesMsg,
                                height: 20,
                                width: 20,
                              ),
                      ),
                      onChanged: controller.onEmailChanged,
                    ),
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
