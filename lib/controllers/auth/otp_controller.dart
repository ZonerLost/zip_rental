import 'dart:async';

import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';

class OtpController extends GetxController {
  OtpController({AuthService? authService})
    : _authService = authService ?? AuthService(),
      _notificationsService = NotificationsService();

  final AuthService _authService;
  final NotificationsService _notificationsService;

  String otpCode = '';
  String pendingEmail = '';
  bool loginVerificationFlow = false;
  int secondsRemaining = 60;
  bool isResendActive = false;
  bool isSubmitting = false;
  Timer? _timer;

  bool get isButtonActive => otpCode.length == 6 && !isSubmitting;
  String get maskedEmail {
    if (pendingEmail.isEmpty || !pendingEmail.contains('@')) {
      return '';
    }
    final parts = pendingEmail.split('@');
    final local = parts.first;
    final domain = parts.last;
    if (local.isEmpty) {
      return '***@$domain';
    }
    if (local.length <= 2) {
      return '${local[0]}***@$domain';
    }
    return '${local.substring(0, 2)}***@$domain';
  }

  String get formattedTime {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map && arguments['loginVerificationFlow'] == true) {
      loginVerificationFlow = true;
    }
    _loadPendingEmail();
    startCountdown();
  }

  Future<void> _loadPendingEmail() async {
    pendingEmail = await _authService.getPendingEmail() ?? '';
    update();
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
    if (pendingEmail.isEmpty) {
      Get.snackbar('Missing Email', 'Unable to resend OTP without email');
      return;
    }
    final result = await _authService.resendVerification(
      ResendVerificationRequest(email: pendingEmail),
    );
    if (!result.success) {
      Get.snackbar('Resend Failed', result.message);
      return;
    }
    startCountdown();
  }

  Future<void> verifyOtp() {
    if (!isButtonActive) {
      return Future.value();
    }

    isSubmitting = true;
    update();

    if (pendingEmail.isEmpty) {
      isSubmitting = false;
      update();
      Get.snackbar('Missing Email', 'Unable to verify OTP without email');
      return Future.value();
    }

    return _authService
        .verifyEmail(
          VerifyEmailRequest(
            email: pendingEmail,
            otp: otpCode,
            type: VerifyOtpType.emailVerification,
          ),
        )
        .then((result) async {
          isSubmitting = false;
          update();

          if (result.success) {
            if (loginVerificationFlow) {
              await _notificationsService.syncSavedFcmTokenOnLaunch();
              Get.offAll(() => const BottomNavBar());
              return;
            }
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
