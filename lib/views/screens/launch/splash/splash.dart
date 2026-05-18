import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/screens/launch/splash/language_start.dart';
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
  final AuthService _authService = AuthService();
  final NotificationsService _notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final accessToken = await _authService.ensureAccessToken();
    if (!mounted) {
      return;
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      print('Access token found: $accessToken');
      await _notificationsService.syncSavedFcmTokenOnLaunch();
      Get.offAll(() => const BottomNavBar());
      return;
    }

    Get.off(() => const LanguageStartScreen());
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
