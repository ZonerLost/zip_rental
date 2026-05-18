import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/google_auth_service.dart';
import 'package:zip_peer/services/auth/auth_validators.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';
import 'package:zip_peer/services/profile/profile_service.dart';
import 'package:zip_peer/views/screens/auth/forgot_password.dart';
import 'package:zip_peer/views/screens/auth/otp.dart';
import 'package:zip_peer/views/screens/auth/signup.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/screens/profile_creation/complete_profile.dart';

class LoginController extends GetxController {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final NotificationsService _notificationsService;
  final ProfileService _profileService;

  LoginController({
    AuthService? authService,
    ProfileService? profileService,
    GoogleAuthService? googleAuthService,
    NotificationsService? notificationsService,
  }) : _authService = authService ?? AuthService(),
       _googleAuthService = googleAuthService ?? GoogleAuthService(),
       _notificationsService = notificationsService ?? NotificationsService(),
       _profileService = profileService ?? ProfileService();

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> tabs = const ['Email address', 'Phone Number'];
  int selectedTabIndex = 0;
  bool isSubmitting = false;

  String get firstHint =>
      selectedTabIndex == 0 ? 'Email address' : 'Phone Number';
  String get firstIcon =>
      selectedTabIndex == 0 ? Assets.imagesMsg : Assets.imagesCall;
  bool get isEmailValid => selectedTabIndex == 0
      ? AuthValidators.isValidEmail(identifierController.text.trim())
      : identifierController.text.trim().length >= 7;
  bool get isButtonActive =>
      identifierController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty &&
      !isSubmitting;

  void selectTab(int index) {
    if (selectedTabIndex == index) return;
    selectedTabIndex = index;
    identifierController.clear();
    update();
  }

  void onIdentifierChanged(String _) => update();
  void onPasswordChanged(String _) => update();

  Future<void> submit() async {
    if (!isButtonActive) return;
    if (selectedTabIndex == 1) {
      Get.snackbar(
        'Unsupported',
        'Phone login is not available. Use email login.',
      );
      return;
    }
    final email = identifierController.text.trim();
    if (!AuthValidators.isValidEmail(email)) {
      Get.snackbar('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    isSubmitting = true;
    update();

    final result = await _authService.login(
      LoginRequest(email: email, password: passwordController.text.trim()),
    );

    isSubmitting = false;
    update();

    if (result.success) {
      await _navigateAfterLogin();
      return;
    }

    final requiresEmailVerification = result.message.toLowerCase().contains(
      'verify your email',
    );
    if (requiresEmailVerification) {
      await _authService.savePendingEmail(email);
      final resendResult = await _authService.resendVerification(
        ResendVerificationRequest(email: email),
      );
      if (!resendResult.success) {
        Get.snackbar(
          'Verification Required',
          'Please verify your email first. We could not resend OTP automatically: ${resendResult.message}',
        );
      }
      Get.to(
        () => const OtpScreen(),
        arguments: <String, dynamic>{'loginVerificationFlow': true},
      );
      return;
    }

    Get.snackbar('Login Failed', result.message);
  }

  Future<void> _navigateAfterLogin() async {
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

  Future<void> continueWithGoogle() async {
    isSubmitting = true;
    update();
    try {
      final idToken = await _googleAuthService.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        isSubmitting = false;
        update();
        return;
      }

      final result = await _authService.googleAuth(
        GoogleAuthRequest(idToken: idToken, language: 'en'),
      );

      isSubmitting = false;
      update();

      if (result.success) {
        await _navigateAfterLogin();
        return;
      }
      Get.snackbar('Google Sign-In Failed', result.message);
    } catch (_) {
      isSubmitting = false;
      update();
      Get.snackbar(
        'Google Sign-In Failed',
        'Unable to authenticate with Google right now.',
      );
    }
  }

  void continueWithApple() {
    Get.snackbar('Not Integrated', 'Apple Sign-In is not available.');
  }

  void openForgotPassword() => Get.to(() => ForgotPasswordScreen());
  void openSignup() => Get.to(() => SignUpScreen());

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
