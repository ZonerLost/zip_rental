import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class CompleteYourProfileScreen extends StatefulWidget {
  const CompleteYourProfileScreen({super.key});

  @override
  State<CompleteYourProfileScreen> createState() =>
      _CompleteYourProfileScreenState();
}

class _CompleteYourProfileScreenState extends State<CompleteYourProfileScreen> {
  final PageController _pageController = PageController();
  int currentStep = 0;

  // Step 1 Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  // Step 3 Controllers
  final TextEditingController _addressTitleController = TextEditingController(
    text: "Home Address",
  );
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _completeAddressController =
      TextEditingController();
  final FocusNode _addressTitleFocus = FocusNode();
  final FocusNode _streetFocus = FocusNode();
  final FocusNode _zipCodeFocus = FocusNode();
  final FocusNode _completeAddressFocus = FocusNode();

  String selectedCountry = "United States of America";
  final List<String> countries = [
    "United States of America",
    "Pakistan",
    "United Kingdom",
    "Canada",
    "Australia",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressTitleController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    _completeAddressController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressTitleFocus.dispose();
    _streetFocus.dispose();
    _zipCodeFocus.dispose();
    _completeAddressFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.to(() => BottomNavBar());
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  double get progressValue => (currentStep + 1) / 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              buttonText: currentStep == 2
                  ? "Confirm"
                  : (currentStep == 1 ? "Upload" : "Continue"),
              onTap: _nextStep,
              height: 60,
              radius: 30,
              fontColor: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            Gap(40),
          ],
        ),
      ),
      body: Column(
        children: [
          Gap(100),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => currentStep = index);
              },
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              text: "Step 1/3",
              size: 14,
              weight: FontWeight.w500,
              color: kSubText2,
            ),
            const Gap(12),
            const MyText(
              text: "Complete your Profile",
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black,
            ),
            const Gap(8),
            const MyText(
              text:
                  "Please enter your personal information to get things started.",
              size: 14,
              weight: FontWeight.w400,
              color: kSubText2,
            ),
            const Gap(40),

            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                width: Get.width,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesPersonIcon,
                      height: 100,
                    ),
                    const Gap(12),
                    const MyText(
                      text: "Upload Profile Photo",
                      size: 20,
                      weight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),

            const Gap(40),
            const MyText(
              text: "CONTACT INFORMATION",
              size: 12,
              weight: FontWeight.w600,
              color: kSubText2,
              letterSpacing: 1,
            ),
            const Gap(20),

            MyTextField(
              hint: "Full Name",
              hintColor: kBlack,
              controller: _nameController,
              focusNode: _nameFocus,
              radius: 12,
              marginBottom: 16,
              onChanged: (_) => setState(() {}),
            ),

            MyTextField(
              hint: "Email address",
              hintColor: kBlack,
              controller: _emailController,
              focusNode: _emailFocus,
              radius: 12,
              marginBottom: 16,

              onChanged: (_) => setState(() {}),
            ),

            MyTextField(
              hint: "Phone number",
              hintColor: kBlack,
              controller: _phoneController,
              focusNode: _phoneFocus,
              radius: 12,
              marginBottom: 16,

              onChanged: (_) => setState(() {}),
            ),

            const Gap(40),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText(
              text: "Step 2/3",
              size: 14,
              weight: FontWeight.w500,
              color: kSubText2,
            ),
            const Gap(12),
            const MyText(
              text: "Verify your Identity",
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black,
            ),
            const Gap(8),
            const MyText(
              text:
                  "Please upload your national ID here to verify your identity.",
              size: 14,
              weight: FontWeight.w400,
              color: kSubText2,
            ),
            const Gap(200),

            Center(
              child: Column(
                children: [
                  CommonImageView(imagePath: Assets.imagesIdCard, height: 80),
                  const Gap(30),
                  const MyText(
                    text: "ID Verification",
                    size: 20,
                    weight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  const Gap(12),
                  const MyText(
                    text:
                        "Please upload your national ID here to\nverify your identity.",
                    size: 14,
                    weight: FontWeight.w400,
                    color: kSubText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Gap(80),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              text: "Step 3/3",
              size: 14,
              weight: FontWeight.w500,
              color: kSubText2,
            ),
            const Gap(8),
            const MyText(
              text: "Add Address",
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black,
            ),
            const Gap(8),
            const MyText(
              text:
                  "Please enter your address that will be used for delivery of items.",
              size: 14,
              weight: FontWeight.w400,
              color: kSubText2,
            ),
            const Gap(30),

            MyTextField(
              label: "Address Title",
              labelColor: kSubText,
              hint: "Home Address",
              labelWeight: FontWeight.w400,
              labelSize: 12,
              hintColor: kBlack,
              controller: _addressTitleController,
              focusNode: _addressTitleFocus,
              radius: 12,
              onChanged: (_) => setState(() {}),
            ),

            MyTextField(
              hint: "St 4, Wilson road",
              label: "Street",
              labelWeight: FontWeight.w400,
              labelSize: 12,
              labelColor: kSubText,
              hintColor: kBlack,
              controller: _streetController,
              focusNode: _streetFocus,
              radius: 12,
              onChanged: (_) => setState(() {}),
            ),

            CustomDropDown(
              hint: 'Select Country',
              items: countries,

              selectedValue: selectedCountry,
              onChanged: (value) {
                setState(() => selectedCountry = value);
              },
              bgColor: Colors.white,
              labelText: null,
            ),

            MyTextField(
              hint: "101223",
              label: "Zip Code",
              labelWeight: FontWeight.w400,
              labelSize: 12,
              labelColor: kSubText,
              hintColor: kBlack,
              controller: _zipCodeController,
              focusNode: _zipCodeFocus,
              radius: 12,
              onChanged: (_) => setState(() {}),
            ),

            MyTextField(
              hint: "St 4, Wilson road, house 34, Brooklyn , USA",
              hintColor: kBlack,
              labelWeight: FontWeight.w400,
              labelSize: 12,
              label: "Complete Address",
              labelColor: kSubText,
              maxLines: 4,
              controller: _completeAddressController,
              focusNode: _completeAddressFocus,
              radius: 12,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ],
    );
  }
}
