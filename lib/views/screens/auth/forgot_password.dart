// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/auth/otp.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FocusNode _focusNodeEmail = FocusNode();

  final TextEditingController _emailController = TextEditingController();

  bool get _isButtonActive => _emailController.text.trim().isNotEmpty;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _focusNodeEmail.dispose();

    _emailController.dispose();
    _agreeToTerms;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kbackground,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Terms Checkbox
              MyButton(
                onTap: () {
                  emailSendBottomSheet(context);
                },

                fontSize: 18,
                radius: 30,
                height: 60,
                buttonText: "Send Verification Link",
                backgroundColor: _isButtonActive
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
                    onTap: () {
                      Get.back(); // Go back to Login
                    },
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
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Bounce(
                    onTap: () => Get.back(),
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
                // Terms & Privacy
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    children: [
                      TextSpan(
                        text:
                            "Please enter the email address that start’s with",
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

                // Email Address
                // Email Field
                MyTextField(
                  hint: "Email address",
                  hintColor: kBlack,
                  controller: _emailController,
                  alwaysShowLabel: true,
                  focusNode: _focusNodeEmail,
                  radius: 24,
                  suffix: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _emailController.text.trim().isNotEmpty
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
                  onChanged: (value) => setState(() {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
