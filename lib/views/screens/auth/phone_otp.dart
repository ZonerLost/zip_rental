import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/auth/phone_otp_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class PhoneOtpScreen extends StatelessWidget {
  const PhoneOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhoneOtpController>(
      init: PhoneOtpController(),
      builder: (controller) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyButton(
                    onTap: controller.verifyOtp,
                    buttonText: 'Continue',
                    height: 60,
                    radius: 30,
                    fontSize: 18,
                    fontColor: Colors.white,
                    backgroundColor: controller.isButtonActive
                        ? kPrimaryColor
                        : kPrimaryColor2,
                    hasgrad: false,
                  ),
                  const Gap(24),
                  Center(
                    child: Bounce(
                      onTap: controller.resendCode,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: kSubText2,
                          ),
                          children: [
                            const TextSpan(text: "Didn't receive code? "),
                            TextSpan(
                              text: controller.isResendActive
                                  ? 'Resend code'
                                  : controller.formattedTime,
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: controller.isResendActive
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationColor: controller.isResendActive
                                    ? kPrimaryColor
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(32),
                ],
              ),
            ),
            backgroundColor: kbackground,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(50),
                  Bounce(
                    onTap: Get.back,
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                  const Gap(20),
                  const MyText(
                    text: 'Verification Code',
                    size: 32,
                    weight: FontWeight.w700,
                    color: kFontText,
                  ),
                  const Gap(12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: kSubText2,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'We have sent a verification code to your phone number ',
                        ),
                        TextSpan(
                          text: controller.maskedPhone.isEmpty
                              ? 'your number'
                              : controller.maskedPhone,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  Center(
                    child: Pinput(
                      length: 6,
                      defaultPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: kWhite, width: 2),
                          color: kWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimaryColor, width: 2),
                          color: kPrimaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimaryColor, width: 2),
                          color: kPrimaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: controller.onOtpChanged,
                      onCompleted: controller.onOtpChanged,
                      showCursor: true,
                      cursor: Container(
                        width: 2,
                        height: 32,
                        color: kPrimaryColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
