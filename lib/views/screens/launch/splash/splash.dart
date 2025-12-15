import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/screens/launch/splash/language_start.dart';
import 'package:zip_peer/views/screens/launch/splash/onboarding.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import '../../../../generated/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Using GetX delayed navigation
    Future.delayed(const Duration(seconds: 5), () {
      Get.off(() => const LanguageStartScreen()); // Replace current screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: MyText(
              text: 'Powered by ZIP',
              color: kPrimaryColor,
              size: 16,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFDEEEEA),
      body: AnimatedColumn(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Animate(
              effects: const [
                MoveEffect(
                  duration: Duration(milliseconds: 500),
                  begin: Offset(0, 20),
                ),
              ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CommonImageView(
                    imagePath: Assets.imagesLogoMain,
                    height: 150,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
