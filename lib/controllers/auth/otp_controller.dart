import 'dart:async';

import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_dummy_service.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';

class OtpController extends GetxController {
  OtpController({AuthDummyService? authService})
    : _authService = authService ?? AuthDummyService();

  final AuthDummyService _authService;

  String otpCode = '';
  int secondsRemaining = 60;
  bool isResendActive = false;
  bool isSubmitting = false;
  Timer? _timer;

  bool get isButtonActive => otpCode.length == 6 && !isSubmitting;
  String get formattedTime {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  void startCountdown() {
    isResendActive = false;
    secondsRemaining = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
      } else {
        isResendActive = true;
        timer.cancel();
      }
      update();
    });
    update();
  }

  void onOtpChanged(String value) {
    otpCode = value;
    update();
  }

  Future<void> resendCode() async {
    if (!isResendActive) {
      return;
    }
    await _authService.resendOtp();
    startCountdown();
  }

  Future<void> verifyOtp() {
    if (!isButtonActive) {
      return Future.value();
    }

    isSubmitting = true;
    update();

    return _authService.verifyOtp(VerifyOtpRequest(code: otpCode)).then((
      result,
    ) {
      isSubmitting = false;
      update();

      if (result.success) {
        showAccountCreatedBottomSheet();
        return;
      }
      Get.snackbar('Verification Failed', result.message);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
