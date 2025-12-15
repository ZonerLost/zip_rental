import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/screens/home/home.dart';
import 'package:zip_peer/views/screens/profile/privacy_policy.dart';
import 'package:zip_peer/views/screens/profile/terms_condition.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  int _selectedPlan = 1; // 0: Basic, 1: Recommended, 2: Premium

  final List<Map<String, dynamic>> _plans = [
    {
      "title": "FREE PACKAGE",
      "price": r"$0.00",
      "duration": "/ 30 days",
      "isRecommended": false,
    },
    {
      "title": "RECOMMENDED",
      "price": r"$39.99",
      "duration": "/ 3 months",
      "isRecommended": true,
    },
    {
      "title": "PREMIUM PACKAGE",
      "price": r"$99.99",
      "duration": "/ early",
      "isRecommended": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: kContainerBackgroundGradeintColor,
        ),
        child: AnimatedListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(60),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      onTap: () {
                        Get.offAll(() => HomeScreen());
                      },
                      text: "Skip",
                      size: 18,
                      weight: FontWeight.w500,
                      color: kPrimaryColor,
                      textAlign: TextAlign.right,
                    ),
                    Bounce(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                // Crown Icon
                Row(
                  children: [
                    // CommonImageView(imagePath: Assets.imagesCrown2, height: 48),
                  ],
                ),
                const Gap(24),

                // Title
                MyText(
                  text: "Premium Plans",
                  size: 24,
                  weight: FontWeight.w600,
                  color: kBlack,
                  textAlign: TextAlign.right,
                ),
                const Gap(12),
                MyText(
                  text: "Enjoy our amazing and affordable subscription plans.",
                  size: 18,
                  weight: FontWeight.w400,
                  color: kSubText2,
                ),
                const Gap(40),

                // Feature List
                _buildFeature("Unlimited Messaging"),
                const Gap(8),
                _buildFeature("Daily Flames to send friend requests."),
                const Gap(8),
                _buildFeature("Ads (Image/video) inside swipe feed."),
                const Gap(20),

                // Pricing Cards
                ..._plans.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plan = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildPlanCard(
                      title: plan["title"],
                      price: plan["price"],
                      duration: plan["duration"],
                      isSelected: _selectedPlan == index,
                      isRecommended: plan["isRecommended"],
                      onTap: () => setState(() => _selectedPlan = index),
                    ),
                  );
                }).toList(),

                const Gap(20),

                // Continue Button
                MyButton(
                  onTap: () {
                    selectPaymentBottomSheet(context);
                  },
                  fontSize: 18,
                  radius: 30,
                  height: 56,
                  isactive: true,
                  buttonText: "Continue",
                  fontColor: Colors.white,
                  hasgrad: false,
                ),
                const Gap(24),

                // Terms & Privacy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      children: [
                        TextSpan(
                          text: "By signing in you agree to ZIP ",
                          style: TextStyle(
                            color: kSubText2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        WidgetSpan(
                          child: Bounce(
                            onTap: () =>
                                Get.to(() => TermsAndConditionsScreen()),
                            child: Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: " and our ",
                          style: TextStyle(
                            color: kSubText2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        WidgetSpan(
                          child: Bounce(
                            onTap: () => Get.to(() => PrivacyPolicyScreen()),
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Row(
      children: [
        CommonImageView(
          imagePath: Assets.imagesDoubleTick,
          height: 24,
          width: 24,
        ),
        const Gap(14),
        Expanded(
          child: MyText(
            text: text,
            size: 14,
            color: kBlack,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String duration,
    required bool isSelected,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return Bounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isSelected ? kButtonGradeintColor : null,
          color: isSelected ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          children: [
            // Recommended Header
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(
                child: MyText(
                  text: title,
                  size: 14,
                  weight: FontWeight.w700,
                  color: isSelected ? Colors.white : kBlack,
                ),
              ),
            ),

            const Gap(12),

            // Inner Rounded White Box (EXACT UI)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: isRecommended ? kButtonGradeintColor : null,
                color: isRecommended ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    /// RADIO CIRCLE
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? kPrimaryColor : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? kPrimaryColor
                              : const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),

                    const Gap(16),

                    /// PRICE + DURATION
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyText(
                            text: price,
                            size: 20,
                            weight: FontWeight.w500,
                            color: kBlack,
                          ),
                          const Gap(6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: MyText(
                              text: duration,
                              size: 16,
                              color: kSubText2,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(6),
          ],
        ),
      ),
    );
  }
}
