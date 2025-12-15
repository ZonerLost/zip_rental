import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import '../../../../generated/assets.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Turn Your Idle\nItems Into Income",
      description:
          "List your tools, gear, or gadgets in minutes and start earning by renting them out to people nearby.",
      imagePath: Assets.imagesOnbaording1,
    ),
    OnboardingData(
      title: "Borrow What You Need,\nWhen You Need It",
      description:
          "Find affordable rentals in your neighborhood no need to buy something you'll only use once.",
      imagePath: Assets.imagesOnboarding2,
    ),
    OnboardingData(
      title: "Save Money,\nSave the Planet.",
      description: "Join a community making an impact with every transaction.",
      imagePath: Assets.imagesOnbaording3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // When it's the last page → go to login
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        child: Column(
          children: [
            // Progress Indicator
            const Gap(50),
            _buildProgressIndicator(),
            const Gap(32),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom Buttons
            const Gap(24),
            MyButton(
              buttonText: "Continue",
              onTap: _nextPage,
              backgroundColor: kPrimaryColor,
              height: 56,
              radius: 30,
              hasgrad: false,
              isactive: true,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontColor: Colors.white,
            ),
            const Gap(16),
            Bounce(
              onTap: () {
                Get.offAll(() => LoginScreen());
              },
              child: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    text: "Already have an Account?",
                    size: 16,
                    color: kSubText,
                    weight: FontWeight.w400,
                  ),
                  MyText(
                    text: "Login",
                    size: 16,
                    color: kPrimaryColor,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(_pages.length, (index) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index < _pages.length - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: index <= _currentPage ? kPrimaryColor : kPrimaryColor3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        MyText(
          text: data.title,
          size: 28,
          weight: FontWeight.w600,
          textAlign: TextAlign.left,
          color: kBlack,
          maxLines: 3,
        ),
        const Gap(16),

        // Description
        MyText(
          text: data.description,
          size: 14,
          textAlign: TextAlign.left,
          color: kSubText2,
          maxLines: 3,
        ),

        const Spacer(),

        // Image
        Center(
          child: CommonImageView(
            imagePath: data.imagePath,
            height: 350,
            fit: BoxFit.contain,
          ),
        ),

        const Spacer(),
      ],
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
