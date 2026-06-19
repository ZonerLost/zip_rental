import 'dart:async';

import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';
import 'package:zip_peer/services/profile/profile_service.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/screens/profile_creation/complete_profile.dart';

class PhoneOtpController extends GetxController {
  PhoneOtpController({
    AuthService? authService,
    NotificationsService? notificationsService,
    ProfileService? profileService,
  })  : _authService = authService ?? AuthService(),
        _notificationsService = notificationsService ?? NotificationsService(),
        _profileService = profileService ?? ProfileService();

  final AuthService _authService;
  final NotificationsService _notificationsService;
  final ProfileService _profileService;

  String otpCode = '';
  String pendingPhone = '';
  String? firstName;
  String? lastName;
  bool isSignupFlow = false;
  int secondsRemaining = 60;
  bool isResendActive = false;
  bool isSubmitting = false;
  Timer? _timer;

  bool get isButtonActive => otpCode.length == 6 && !isSubmitting;

  String get maskedPhone {
    if (pendingPhone.length <= 4) return pendingPhone;
    final visibleStart = pendingPhone.length >= 7 ? 3 : 2;
    return '${pendingPhone.substring(0, visibleStart)}****'
        '${pendingPhone.substring(pendingPhone.length - 2)}';
  }

  String get formattedTime {
    final m = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      pendingPhone = (args['phone'] ?? '').toString();
      isSignupFlow = args['isSignupFlow'] == true;
      firstName = args['firstName']?.toString();
      lastName = args['lastName']?.toString();
    }
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
    if (!isResendActive) return;
    if (pendingPhone.isEmpty) {
      Get.snackbar('Error', 'Phone number not found.');
      return;
    }
    final result = await _authService.resendPhoneOtp(
      PhoneResendOtpRequest(phone: pendingPhone),
    );
    if (!result.success) {
      Get.snackbar('Resend Failed', result.message);
      return;
    }
    startCountdown();
  }

  Future<void> verifyOtp() async {
    if (!isButtonActive) return;
    if (pendingPhone.isEmpty) {
      Get.snackbar('Error', 'Phone number not found.');
      return;
    }

    isSubmitting = true;
    update();

    final result = await _authService.verifyPhoneOtp(
      PhoneVerifyOtpRequest(
        phone: pendingPhone,
        otp: otpCode,
        firstName: isSignupFlow ? firstName : null,
        lastName: isSignupFlow ? lastName : null,
      ),
    );

    isSubmitting = false;
    update();

    if (!result.success) {
      Get.snackbar('Verification Failed', result.message);
      return;
    }

    await _authService.clearPendingPhone();
    await _notificationsService.syncSavedFcmTokenOnLaunch();
    final profileResult = await _profileService.getProfile();
    final profile = profileResult.profile;
    final isComplete =
        profile != null &&
        (profile.phone ?? '').trim().isNotEmpty &&
        (profile.location?.city ?? '').trim().isNotEmpty;
    if (isComplete) {
      Get.offAll(() => const BottomNavBar());
    } else {
      Get.offAll(() => CompleteYourProfileScreen());
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
