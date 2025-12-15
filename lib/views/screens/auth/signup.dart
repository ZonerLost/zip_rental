// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/screens/auth/otp.dart';
import 'package:zip_peer/views/screens/home/home.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _firstFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Tab state
  int _selectedTabIndex = 0; // 0 = Email, 1 = Phone
  final List<String> _tabs = ["Email address", "Phone Number"];

  // Dynamic hint & icon
  String get _firstHint => _tabs[_selectedTabIndex].split(" ").first == "Email"
      ? "Email address"
      : "Phone Number";

  String get _firstIcon => _selectedTabIndex == 0
      ? Assets.imagesMsg
      : Assets.imagesCall; // Make sure you have phone icon

  bool get _isButtonActive =>
      _firstController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _firstController.dispose();
    _passwordController.dispose();
    _firstFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_firstFocus.hasFocus || _passwordFocus.hasFocus) {
          _firstFocus.unfocus();
          _passwordFocus.unfocus();
        }
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
                // Back Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 50,
                      ),
                    ),
                  ],
                ),
                Gap(40),
                // Title
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

                // YOUR CUSTOM TABS
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = _selectedTabIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                              // Optional: Clear field on tab switch
                              _firstController.clear();
                            });
                          },
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
                                text: _tabs[index],
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

                // First Field (Email or Phone)
                MyTextField(
                  hint: _firstHint,
                  hintColor: kBlack,
                  controller: _firstController,
                  focusNode: _firstFocus,
                  radius: 25,
                  suffix: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CommonImageView(imagePath: _firstIcon, height: 24),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                // Password Field
                MyTextField(
                  hint: "Create Password",
                  hintColor: kBlack,
                  controller: _passwordController,
                  isObSecure: true,
                  focusNode: _passwordFocus,
                  radius: 25,
                  suffix: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CommonImageView(
                      imagePath: Assets.imagesEye,
                      height: 24,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const Gap(120),

                // Use Face ID
                Bounce(
                  onTap: () {
                    // Face ID logic
                  },
                  child: CustomCheckbox(
                    text: " Enable Face ID",
                    onChanged: (bool p1) {},
                  ),
                ),

                Gap(24),

                // Continue Button
                MyButton(
                  onTap: () {
                    Get.to(() => OtpScreen());
                  },
                  fontSize: 18,
                  radius: 30,
                  height: 56,
                  backgroundColor: _isButtonActive
                      ? kPrimaryColor
                      : kPrimaryColor2,
                  buttonText: "Continue",
                  fontColor: Colors.white,
                  hasgrad: false,
                ),
                const Gap(20),

                // OR Divider
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

                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonImageView(imagePath: Assets.imagesGoogle, height: 58),
                    const Gap(16),
                    CommonImageView(
                      imagePath: Assets.imagesAppleButton,
                      height: 58,
                    ),
                  ],
                ),
                const Gap(20),

                // Register Link
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
                        onTap: () => Get.to(() => LoginScreen()),
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
  }
}
