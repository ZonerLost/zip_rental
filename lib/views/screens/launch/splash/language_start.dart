// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/launch/splash/onboarding.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:bounce/bounce.dart';

class LanguageStartScreen extends StatefulWidget {
  const LanguageStartScreen({super.key});

  @override
  State<LanguageStartScreen> createState() => _LanguageStartScreenState();
}

class _LanguageStartScreenState extends State<LanguageStartScreen> {
  String _selected = "en"; // default English

  final List<Map<String, dynamic>> _langs = [
    {"code": "en", "flag": "🇬🇧", "name": "English"},
    {"code": "de", "flag": "🇩🇪", "name": "German"},
    {"code": "zh", "flag": "🇨🇳", "name": "Chinese"},
    {"code": "nl", "flag": "🇳🇱", "name": "Dutch"},
    {"code": "fr", "flag": "🇫🇷", "name": "French"},
    {"code": "ar", "flag": "🇸🇦", "name": "Arabic"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(50),

            // Header
            Row(
              children: [
                Bounce(
                  onTap: () => Get.back(),
                  child: CommonImageView(
                    imagePath: Assets.imagesBack,
                    height: 50,
                  ),
                ),
                const Gap(10),
                MyText(
                  text: "Language",
                  size: 18,
                  color: kBlack,
                  weight: FontWeight.w600,
                ),
              ],
            ),
            const Gap(40),

            // Language List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(0),
                itemCount: _langs.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (_, i) {
                  final lang = _langs[i];
                  final bool isSelected = _selected == lang["code"];
                  return Bounce(
                    onTap: () => setState(() => _selected = lang["code"]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          MyText(
                            text: lang["flag"],
                            size: 32,
                            color: kBlack,
                            weight: FontWeight.w500,
                          ),

                          const Gap(16),
                          MyText(
                            text: lang["name"],
                            size: 16,
                            color: kBlack,
                            weight: FontWeight.w500,
                          ),
                          const Spacer(),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: CommonImageView(
                                imagePath: Assets.imagesCheckGreen,
                                height: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Gap(30),

            // Confirm Button
            MyButton(
              height: 60,
              buttonText: "Confirm",
              onTap: () {
                Get.to(() => OnBoardingScreen());
              },
              backgroundColor: kPrimaryColor,
              fontColor: kWhite,
              radius: 30,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }
}
