import 'dart:async';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:pinput/pinput.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = "";
  bool get _isButtonActive => otpCode.length == 6;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isResendActive = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _isResendActive = false;
      _secondsRemaining = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isResendActive = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _onResendTap() {
    if (!_isResendActive) return;

    // TODO: Add resend OTP logic here
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyButton(
                onTap: () {
                  showAccountCreatedBottomSheet(context);
                },
                buttonText: "Continue",
                height: 60,
                radius: 30,

                fontSize: 18,
                fontColor: Colors.white,
              ),

              const Gap(24),

              Center(
                child: Bounce(
                  onTap: _onResendTap,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: kSubText2),
                      children: [
                        const TextSpan(text: "Didn't receive code? "),
                        TextSpan(
                          text: _isResendActive
                              ? "Resend code"
                              : "${_formatTime(_secondsRemaining)}",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: _isResendActive
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            decorationColor: _isResendActive
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

              // Back Button
              Bounce(
                onTap: () => Get.back(),
                child: CommonImageView(
                  imagePath: Assets.imagesBack,
                  height: 50,
                ),
              ),

              const Gap(20),

              const MyText(
                text: "Verification Code",
                size: 32,
                weight: FontWeight.w700,
                color: kFontText,
              ),

              const Gap(12),

              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: kSubText2, height: 1.5),
                  children: [
                    TextSpan(
                      text:
                          "We have sent a verification code to your email address ",
                    ),
                    TextSpan(
                      text: "chri****@gmail.com",
                      style: TextStyle(
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
                  onChanged: (value) => setState(() => otpCode = value),
                  onCompleted: (pin) => setState(() => otpCode = pin),
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
  }
}
