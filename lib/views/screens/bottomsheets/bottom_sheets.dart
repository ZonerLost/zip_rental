// ignore_for_file: non_constant_identifier_names

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/auth/reset_password.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/screens/home/home.dart';
import 'package:zip_peer/views/screens/profile_creation/complete_profile.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/double_white_contianers.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

void showAccountCreatedBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    DoubleWhiteContainers(
      height: 550,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,

      borderRadius: BorderRadius.circular(24),

      child: Container(
        decoration: const BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 48,
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden Circle + Checkmark
              Center(
                child: CommonImageView(
                  imagePath: Assets.imagesSucess, // golden checkmark asset
                  height: 150,
                ),
              ),
              const Gap(32),

              // Title
              const MyText(
                text: "Account Created",
                size: 26,
                weight: FontWeight.w700,
                color: Colors.black,
                textAlign: TextAlign.center,
              ),
              const Gap(16),

              // Subtitle
              const MyText(
                text:
                    "You have successfully created your account. You are only one step away for completing your account.",
                size: 16,
                color: kSubText2,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              const Gap(32),

              // Done Button
              MyButton(
                onTap: () {
                  Get.to(() => CompleteYourProfileScreen());
                },
                buttonText: "Done",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    ),
  );
}

void emailSendBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    DoubleWhiteContainers(
      height: 550,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,

      borderRadius: BorderRadius.circular(24),

      child: Container(
        decoration: const BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 48,
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden Circle + Checkmark
              Center(
                child: CommonImageView(
                  imagePath: Assets.imagesSucess, // golden checkmark asset
                  height: 150,
                ),
              ),
              const Gap(32),

              // Title
              const MyText(
                text: "Mail Sent !",
                size: 26,
                weight: FontWeight.w700,
                color: Colors.black,
                textAlign: TextAlign.center,
              ),
              const Gap(16),

              // Subtitle
              const MyText(
                text:
                    "We have sent an mail on your given email address. Please verify and reset your password.",
                size: 16,
                color: kSubText2,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              const Gap(30),

              // Done Button
              MyButton(
                onTap: () {
                  Get.back();
                  Get.to(() => ResetPasswordScreen());
                },
                buttonText: "Check email",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    ),
  );
}

void selectPaymentBottomSheet(BuildContext context) {
  int selectedPaymentIndex = 0;

  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: 600,
          mainColor: kWhite3,
          topColor: kWhite,
          handleHeight: 14,

          borderRadius: BorderRadius.circular(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 24),
                    Gap(8),
                    MyText(
                      text: "Back",
                      size: 16,
                      weight: FontWeight.w600,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // Title
              const MyText(
                text: "Select Payment",
                size: 26,
                weight: FontWeight.w700,
                color: Colors.black,
                textAlign: TextAlign.center,
              ),

              const Gap(8),

              // Subtitle
              const MyText(
                text: "Please select the preferred payment method.",
                size: 16,
                weight: FontWeight.w400,
                color: kSubText2,
                textAlign: TextAlign.center,
              ),
              const Gap(32),

              // Payment Options Grid
              Row(
                children: [
                  Expanded(
                    child: _paymentTile(
                      Image: Assets.imagesCardIcon,
                      label: "Debit/Credit Card",
                      isSelected: selectedPaymentIndex == 0,
                      onTap: () {
                        setState(() => selectedPaymentIndex = 0);
                      },
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: _paymentTile(
                      Image: Assets.imagesApplePayLogo,
                      label: "Apply Pay",
                      isSelected: selectedPaymentIndex == 1,
                      onTap: () {
                        setState(() => selectedPaymentIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
              const Gap(16),

              Row(
                children: [
                  Expanded(
                    child: _paymentTile(
                      label: "Google Pay",
                      isSelected: selectedPaymentIndex == 2,
                      onTap: () {
                        setState(() => selectedPaymentIndex = 2);
                      },
                      Image: Assets.imagesLogosGooglePay,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: _paymentTile(
                      label: "American Express",
                      isSelected: selectedPaymentIndex == 3,
                      onTap: () {
                        setState(() => selectedPaymentIndex = 3);
                      },
                      Image: Assets.imagesAmericanExpress,
                    ),
                  ),
                ],
              ),
              const Gap(40),

              // Confirm Button
              MyButton(
                onTap: () {
                  Get.back();
                  AppleBottomSheet(context);
                },
                buttonText: "Confirm",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        );
      },
    ),
  );
}

Widget _paymentTile({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
  required String Image,
}) {
  return Bounce(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor.withOpacity(0.3) : kWhite,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: kPrimaryColor, width: 2) : null,
      ),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon/Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              CommonImageView(imagePath: Image, height: 24),
              if (isSelected) ...[
                const Gap(12),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryColor,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ],
            ],
          ),
          const Gap(12),

          // Label
          Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          // Selected Indicator
        ],
      ),
    ),
  );
}

void AppleBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    barrierColor: Colors.black.withOpacity(0.3), // optional: dim background
    DoubleWhiteContainers(
      height: 650,
      mainColor: const Color(0xFFF5F5F5),
      topColor: const Color(0xFFF5F5F5),
      handleHeight: 0,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Apple Pay Logo + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonImageView(
                  imagePath: Assets.imagesApplePayLogo,
                  height: 32,
                ),
                Bounce(
                  onTap: () => Get.back(),
                  child: CommonImageView(
                    imagePath: Assets.imagesClose,
                    height: 40,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Apple Card Option
            _buildPaymentOption(
              iconPath: Assets.imagesCard,
              title: "Apple Card",
              subtitle1: "10880 Malibu Point Malibu Cal",
              subtitle2: "•••• 1234",
              onTap: () {
                Get.back(); // Close Apple Pay sheet FIRST
                Future.delayed(const Duration(milliseconds: 350), () {
                  // ✅ FIX: use Get.context instead of old one
                  final ctx = Get.context;
                  if (ctx != null) cardInfoBottomSheet(ctx);
                });
              },
            ),
            const Gap(16),

            // Contact Info
            _buildPaymentOption(
              icon: Icons.person_outline,
              iconBackground: const Color(0xFFF5F5F5),
              title: "Contact",
              subtitle1: "astark@starkindustries.com",
              subtitle2: "(123) 456-7890",
              onTap: () {
                Get.back(); // Close Apple Pay sheet FIRST
                Future.delayed(const Duration(milliseconds: 100), () {
                  // ✅ FIX: use Get.context instead of old one
                  final ctx = Get.context;
                  if (ctx != null) cardInfoBottomSheet(ctx);
                });
              },
            ),
            const Gap(24),

            const Divider(color: Color(0xFFE0E0E0), thickness: 1),
            const Gap(24),

            // Payment Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "Pay Stark Industries",
                      size: 13,
                      color: kSubText2,
                      weight: FontWeight.w400,
                    ),
                    const Gap(6),
                    MyText(
                      text: "\$19.99",
                      size: 28,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                  size: 32,
                ),
              ],
            ),
            const Gap(24),

            const Divider(color: Color(0xFFE0E0E0), thickness: 1),
            const Gap(24),

            Center(
              child: CommonImageView(
                imagePath: Assets.imagesConfirmPayment,
                height: 70,
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPaymentOption({
  String? iconPath,
  IconData? icon,
  Color? iconBackground,
  required String title,
  required String subtitle1,
  required String subtitle2,
  required VoidCallback onTap,
}) {
  return Bounce(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground ?? Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconPath != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CommonImageView(imagePath: iconPath, height: 32),
                  )
                : Icon(icon, color: Colors.black, size: 26),
          ),
          const Gap(16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: title,
                  size: 16,
                  color: kBlack,
                  weight: FontWeight.w500,
                ),
                const Gap(4),
                MyText(
                  text: subtitle1,
                  size: 14,
                  color: kSubText2,
                  weight: FontWeight.w400,
                ),
                const Gap(2),
                MyText(
                  text: subtitle2,
                  size: 14,
                  color: kSubText2,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),

          // Chevron
          const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 28),
        ],
      ),
    ),
  );
}

void cardInfoBottomSheet(BuildContext context) {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();

  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final FocusNode _focusNodeCard = FocusNode();
  final FocusNode _focusNodeCardname = FocusNode();

  final FocusNode _focusNodeExpiry = FocusNode();
  final FocusNode _focusNodeCvv = FocusNode();

  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: 600,
          mainColor: kWhite3,
          topColor: kWhite,
          handleHeight: 14,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 24),
                    Gap(8),
                    MyText(
                      text: "Back",
                      size: 16,
                      weight: FontWeight.w600,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(32),

              // Title & Subtitle
              const MyText(
                text: "Enter Card Information",
                size: 24,
                weight: FontWeight.w700,
                color: Colors.black,
              ),
              const Gap(8),
              const MyText(
                text: "Please enter your credit or debit card details",
                size: 14,
                color: kSubText2,
                weight: FontWeight.w400,
              ),
              const Gap(32),

              // Card Fields
              MyTextField(
                hint: "Card Number",
                hintColor: kBlack,
                controller: _cardNumberController,
                alwaysShowLabel: true,
                focusNode: _focusNodeCard,
                radius: 12,
                suffix: CommonImageView(
                  imagePath: Assets.imagesLogosMastercard,
                  height: 24,
                ),
              ),
              // --- Card Number Field ---
              MyTextField(
                hint: "Card Holder Name",
                hintColor: kBlack,
                controller: _cardNameController,
                alwaysShowLabel: true,
                focusNode: _focusNodeCardname,
                radius: 12,
                suffix: CommonImageView(
                  imagePath: Assets.imagesLogosMastercard,
                  height: 24,
                ),
              ),

              const Gap(20),

              // --- Expiry Date Field ---
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      hint: "Expiry Date (MM/YY)",
                      hintColor: kBlack,
                      controller: _expiryController,
                      alwaysShowLabel: true,
                      focusNode: _focusNodeExpiry,
                      radius: 12,
                    ),
                  ),

                  const Gap(20),

                  // --- CVV Field ---
                  Expanded(
                    child: MyTextField(
                      hint: "CVV",

                      hintColor: kBlack,
                      controller: _cvvController,
                      alwaysShowLabel: true,
                      focusNode: _focusNodeCvv,
                      radius: 12,
                    ),
                  ),
                ],
              ),

              const Gap(20),

              MyButton(
                onTap: () {
                  Get.back();
                  showRequestSentBottomSheet(context);
                },
                buttonText: "Confirm",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        );
      },
    ),
  );
}

void showDisputeReasonBottomSheet(BuildContext context) {
  String selectedBureau = 'Trans Union';
  String? selectedReason;

  final List<String> bureaus = ['Trans Union', 'Equifax', 'Experian'];
  final List<String> reasons = [
    'This item is fraudulent or identity theft',
    'I was never late on this account',
    'This item was included in bankruptcy',
    'I did not authorize myself to be a user on this\naccount',
    'I did not authorize this inquiry',
    'This is an obsolete account that is more than seven\nyears from date of last payment',
    'This account does not belong to me',
    'I paid this to the creditor and they agreed to delete\nit from my credit report',
  ];

  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    DoubleWhiteContainers(
      height: MediaQuery.of(context).size.height * 0.7,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 24),
                  Gap(8),
                  MyText(
                    text: "Back",
                    size: 16,
                    weight: FontWeight.w600,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Gap(32),
            const Text(
              'Choose dispute reason',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Gap(8),
            Text(
              'Tell us why you\'re disputing the selected item.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Gap(24),

            // Credit Bureau Dropdown
            CustomDropDown(
              hint: 'Select Credit Bureau',
              items: bureaus,
              selectedValue: selectedBureau,
              onChanged: (value) {
                setState(() => selectedBureau = value);
              },
              bgColor: Colors.white,
              labelText: null,
            ),

            // Dispute Reasons – now using CustomCheckbox
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  final reason = reasons[index];
                  final bool isSelected = selectedReason == reason;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomCheckbox3(
                            text: reason,
                            textcolor: kBlack,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = isSelected ? null : reason;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Gap(24),

            // Generate Letter Button
            MyButton(
              onTap: () {
                if (selectedReason != null) {
                  Get.back();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    ReviewBottomSheet(context);
                  });
                }
              },
              buttonText: "Generate Letter",
              backgroundColor: selectedReason != null ? kBlack : kBlack100,
              fontColor: Colors.white,
              height: 60,
              radius: 30,
              fontSize: 18,
              hasgrad: false,
            ),

            const Gap(16),
          ],
        ),
      ),
    ),
  );
}

void ReviewBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: 600,
          mainColor: kWhite3,
          topColor: kWhite,
          handleHeight: 14,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, size: 24),
                    Gap(8),
                    MyText(
                      text: "Back",
                      size: 16,
                      weight: FontWeight.w600,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(32),
              const MyText(
                text: "Review Dispute Details",
                size: 24,
                weight: FontWeight.w700,
                color: Colors.black,
              ),
              const Gap(8),
              const MyText(
                text:
                    "Check your information before generating your dispute letter",
                size: 14,
                color: kSubText2,
                weight: FontWeight.w400,
              ),
              const Gap(20),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(54, 234, 234, 234),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: "Date & Time",
                          size: 14,
                          color: kSubText2,
                          weight: FontWeight.w400,
                        ),
                        MyText(
                          text: "Oct 23 | 12:00 PM",
                          size: 14,
                          color: kBlack,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Gap(10),

                    Divider(color: const Color.fromARGB(255, 214, 213, 213)),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        MyText(
                          text: "Credit bureau",
                          size: 14,
                          color: kSubText2,
                          weight: FontWeight.w400,
                        ),
                        MyText(
                          text: "Trans Union",
                          size: 14,
                          color: kBlack,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Gap(10),

                    Divider(color: const Color.fromARGB(255, 214, 213, 213)),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        MyText(
                          text: "Account name",
                          size: 14,
                          color: kSubText2,
                          weight: FontWeight.w400,
                        ),
                        MyText(
                          text: "Chase one",
                          size: 14,
                          color: kBlack,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Gap(10),

                    Divider(color: const Color.fromARGB(255, 214, 213, 213)),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        MyText(
                          text: "Type",
                          size: 14,
                          color: kSubText2,
                          weight: FontWeight.w400,
                        ),
                        MyText(
                          text: "Collection",
                          size: 14,
                          color: kBlack,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Gap(10),

                    Divider(color: const Color.fromARGB(255, 214, 213, 213)),
                    Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        MyText(
                          text: "Dispute reason",
                          size: 14,
                          color: kSubText2,
                          weight: FontWeight.w400,
                        ),
                        MyText(
                          text: "The inquiry was unauthorized.",
                          size: 14,
                          color: kBlack,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Gap(10),
                  ],
                ),
              ),
              Gap(20),
              MyButton(
                onTap: () {
                  Get.back();
                },
                buttonText: "Add to Dispute Letter",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        );
      },
    ),
  );
}

// Helper: Distance Chip
Widget _buildDistanceChip(String label, bool isSelected, VoidCallback onTap) {
  return Bounce(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: MyText(
        text: label,
        size: 14,
        color: isSelected ? kPrimaryColor : Colors.black87,
      ),
    ),
  );
}

void showFiltersBottomSheet(BuildContext context) {
  // Profile Type Selection

  final TextEditingController locationController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();

  String selectedLookingFor = 'Footwear';
  double selectedDistance = 2.5; // in km

  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    DoubleWhiteContainers(
      height: MediaQuery.of(context).size.height * 0.75,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Get.back(),
              child: Row(
                children: [
                  CommonImageView(
                    imagePath: Assets.imagesBackSimple,
                    height: 32,
                  ),
                  Gap(8),
                  MyText(
                    text: "Back",
                    size: 16,
                    weight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Title
            const MyText(
              text: "Select Filters",
              size: 20,
              weight: FontWeight.w600,
              color: Colors.black,
            ),
            const Gap(4),
            MyText(
              text: "Please select the filters as per your preferences.",
              size: 14,
              color: Colors.grey[600],
            ),

            const Gap(8),
            Divider(color: kDividerColor),
            const Gap(8),

            // Profile Types
            MyText(
              text: "Search products",
              size: 14,
              weight: FontWeight.w500,
              color: Colors.black87,
            ),
            const Gap(12),
            MyTextField(
              controller: locationController,
              hint: "Search ",
              hintColor: kBlack,
              hintWeight: FontWeight.w600,
              suffix: CommonImageView(
                imagePath: Assets.imagesMynauiSearch,
                height: 24,
              ),
              radius: 12,
              backgroundColor: Colors.white,
            ),
            MyText(
              text: "Select Category",
              size: 16,
              weight: FontWeight.w600,
              color: kSubText2,
            ),
            const Gap(12),
            CustomDropDown(
              hint: 'Footwear',
              items: const [
                'Footwear',
                'Mens Outfit',
                'Womens Outfit',
                'Children Outfit',
                'Jacket',
              ],
              selectedValue: selectedLookingFor,
              onChanged: (value) {
                setState(() => selectedLookingFor = value);
              },
              bgColor: Colors.white,
              labelText: null,
            ),
            const Gap(12),

            MyText(
              text: "Search by location",
              size: 16,
              weight: FontWeight.w600,
              color: kSubText2,
            ),
            const Gap(12),
            MyTextField(
              controller: hashtagController,
              hint: "Brookyln , USA",
              hintColor: kBlack,
              hintWeight: FontWeight.w600,
              suffix: CommonImageView(
                imagePath: Assets.imagesMynauiSearch,
                height: 24,
              ),
              radius: 12,
              backgroundColor: Colors.white,
            ),

            const Gap(24),

            // Distance
            Row(
              children: [
                MyText(
                  text: "Distance",
                  size: 16,
                  weight: FontWeight.w600,
                  color: kSubText2,
                ),
              ],
            ),

            const Gap(16),
            Row(
              children: [
                _buildDistanceChip(
                  "500 m",
                  selectedDistance == 0.5,
                  () => setState(() => selectedDistance = 0.5),
                ),
                const Gap(8),
                _buildDistanceChip(
                  "2.5 km",
                  selectedDistance == 2.5,
                  () => setState(() => selectedDistance = 2.5),
                ),
                const Gap(8),
                _buildDistanceChip(
                  "5 km",
                  selectedDistance == 5.0,
                  () => setState(() => selectedDistance = 5.0),
                ),
                const Gap(8),
                _buildDistanceChip(
                  "10 km +",
                  selectedDistance == 10.0,
                  () => setState(() => selectedDistance = 10.0),
                ),
              ],
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    onTap: () {
                      // Reset all
                    },
                    buttonText: "Reset",
                    backgroundColor: Colors.white,
                    fontColor: Colors.black,
                    height: 50,
                    radius: 30,
                    fontSize: 16,
                    hasgrad: false,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: MyButton(
                    onTap: () {
                      // Apply filters logic here
                      Get.back();
                      // Pass data back or apply filters
                    },
                    buttonText: "Apply",
                    backgroundColor: kPrimaryColor,
                    fontColor: Colors.white,
                    height: 50,
                    radius: 30,
                    fontSize: 16,
                    hasgrad: false,
                  ),
                ),
              ],
            ),
            const Gap(16),
          ],
        ),
      ),
    ),
  );
}

void showSelectAddressBottomSheet(BuildContext context) {
  int selectedAddressIndex = 0;

  final List<Map<String, dynamic>> addresses = [
    {
      'title': 'Home Address',
      'address': 'St3 , Wilson road , Brooklyn, 10121',
      'distance': '1.5 KM',
      'fee': '\$10.00 delivery fees',
    },
    {
      'title': 'Office Address',
      'address': 'St3 , Wilson road , Brooklyn, USA 10121',
      'distance': '10.4 KM',
      'fee': '\$45.00 delivery fees',
    },
    {
      'title': 'Friends Address',
      'address': 'St3 , Wilson road , Brooklyn, USA 10121',
      'distance': '1.5 KM',
      'fee': '\$10.00 delivery fees',
    },
  ];

  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    StatefulBuilder(
      builder: (context, setState) {
        return DoubleWhiteContainers(
          height: MediaQuery.of(context).size.height * 0.85,
          mainColor: kbackground,
          topColor: kWhite,
          handleHeight: 14,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesBackSimple,
                      height: 30,
                    ),
                    Gap(8),
                    MyText(
                      text: "Back",
                      size: 18,
                      weight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Title
              const MyText(
                text: "Select Address",
                size: 20,
                weight: FontWeight.w700,
                color: Colors.black,
              ),
              const Gap(8),
              MyText(
                text: "Please select the address from your added ones.",
                size: 14,
                color: kSubText2,
                weight: FontWeight.w400,
              ),
              const Gap(24),

              // Address List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final isSelected = selectedAddressIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Bounce(
                        onTap: () {
                          setState(() {
                            selectedAddressIndex = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: address['title'],
                                    size: 18,
                                    weight: FontWeight.w600,
                                    color: kBlack,
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: kWhite,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              Gap(8),
                              MyText(
                                text: address['address'],
                                size: 14,
                                color: kSubText2,
                                weight: FontWeight.w400,
                              ),
                              Gap(12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: address['distance'],
                                      size: 16,
                                      weight: FontWeight.w600,
                                      color: kBlack,
                                    ),
                                    MyText(
                                      text: address['fee'],
                                      size: 16,
                                      weight: FontWeight.w600,
                                      color: kSubText2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              MyButton(
                onTap: () {
                  Get.back();
                },
                buttonText: "+ Add New Address",
                fontColor: kPrimaryColor,
                backgroundColor: kPrimaryColor.withOpacity(0.2),
                height: 56,
                radius: 28,
                hasicon: true,
                hasgrad: false,
                fontSize: 17,
              ),
              Gap(20),

              // Continue Button
              MyButton(
                onTap: () {
                  Get.back();
                },
                buttonText: "Continue",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        );
      },
    ),
  );
}

void showRequestSentBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: false,
    DoubleWhiteContainers(
      height: Get.height * 0.95,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(40),
            CommonImageView(imagePath: Assets.imagesSucess, height: 150),
            const Gap(40),

            // Title
            const MyText(
              text: "Request Sent!",
              size: 28,
              weight: FontWeight.w700,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            const Gap(16),

            // Description
            const MyText(
              text:
                  "Your request for renting this item has been sent to the owner of the product , you'll receive a notification once approved",
              size: 15,
              color: kSubText2,
              weight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            const Gap(32),

            // Order Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite3,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Date & Time", "Oct 23 | 12:00 PM"),
                  Gap(6),
                  Divider(color: kDividerColor),
                  Gap(6),
                  _buildDetailRow("Rented Duration", "2 months"),
                  Gap(6),
                  Divider(color: kDividerColor),
                  Gap(6),
                  _buildDetailRow("Order Type", "Pickup"),
                  Gap(6),
                  Divider(color: kDividerColor),
                  Gap(6),
                  _buildDetailRow("Amount in escrow", "\$100.00"),
                  Gap(6),
                  Divider(color: kDividerColor),
                  Gap(6),
                  _buildDetailRow("Payment Method Used", "Master card ***56"),
                ],
              ),
            ),
            Spacer(),

            // Info Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: kSubText2, size: 20),
                  Gap(8),
                  Expanded(
                    child: MyText(
                      text: "On your way to save 1kg of Co2",
                      size: 14,
                      color: kSubText2,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Go to Home Page Button
            MyButton(
              onTap: () {
                Get.back();
                Get.off(() => const BottomNavBar(initialIndex: 0));
              },
              buttonText: "Go to Home Page",
              fontColor: Colors.white,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 17,
            ),
            const Gap(20),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      MyText(text: label, size: 14, color: kSubText2, weight: FontWeight.w400),
      MyText(text: value, size: 14, color: kBlack, weight: FontWeight.w600),
    ],
  );
}

void ItemAddedBottomSheet(BuildContext context) {
  Get.bottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: false,
    DoubleWhiteContainers(
      height: 550,
      mainColor: kWhite3,
      topColor: kWhite,
      handleHeight: 14,

      borderRadius: BorderRadius.circular(24),

      child: Container(
        decoration: const BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 48,
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden Circle + Checkmark
              Center(
                child: CommonImageView(
                  imagePath: Assets.imagesSucess, // golden checkmark asset
                  height: 150,
                ),
              ),
              const Gap(32),

              // Title
              const MyText(
                text: "Item Added!",
                size: 26,
                weight: FontWeight.w700,
                color: Colors.black,
                textAlign: TextAlign.center,
              ),
              const Gap(16),

              // Subtitle
              const MyText(
                text:
                    "Your item has been successfully listed to the customers, You’ll receive a confirmation mail soon.",
                size: 16,
                color: kSubText2,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              const Gap(30),

              // Done Button
              MyButton(
                onTap: () {
                  Get.back();
                  Get.to(() => BottomNavBar(initialIndex: 2));
                },
                buttonText: "Done",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    ),
  );
}
