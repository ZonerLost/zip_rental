import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/google_auth_service.dart';
import 'package:zip_peer/services/auth/auth_validators.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/screens/auth/otp.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';

class SignupController extends GetxController {
  SignupController({AuthService? authService, GoogleAuthService? googleAuth})
    : _authService = authService ?? AuthService(),
      _googleAuthService = googleAuth ?? GoogleAuthService(),
      _notificationsService = NotificationsService();

  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final NotificationsService _notificationsService;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> tabs = const ['Email address', 'Phone Number'];
  int selectedTabIndex = 0;
  bool useFaceId = false;
  bool isSubmitting = false;

  String get firstHint =>
      selectedTabIndex == 0 ? 'Email address' : 'Phone Number';
  String get firstIcon =>
      selectedTabIndex == 0 ? Assets.imagesMsg : Assets.imagesCall;
  bool get isEmailValid => selectedTabIndex == 0
      ? AuthValidators.isValidEmail(identifierController.text.trim())
      : identifierController.text.trim().length >= 7;
  bool get isPasswordStrong =>
      AuthValidators.isStrongPassword(passwordController.text.trim());
  bool get isButtonActive =>
      firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty &&
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
  void onFirstNameChanged(String _) => update();
  void onLastNameChanged(String _) => update();

  void onFaceIdChanged(bool value) {
    useFaceId = value;
    update();
  }

  Future<void> submit() async {
    if (!isButtonActive) return;
    if (selectedTabIndex == 1) {
      Get.snackbar(
        'Unsupported',
        'Phone signup is not available. Use email signup.',
      );
      return;
    }
    final email = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (!AuthValidators.isValidEmail(email)) {
      Get.snackbar('Invalid Email', 'Please enter a valid email address.');
      return;
    }
    if (!AuthValidators.isStrongPassword(password)) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 8 characters with uppercase, lowercase, and a number.',
      );
      return;
    }

    isSubmitting = true;
    update();

    final result = await _authService.register(
      RegisterRequest(
        email: email,
        password: password,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        language: 'en',
      ),
    );

    isSubmitting = false;
    update();

    if (result.success) {
      Get.to(() => OtpScreen());
      return;
    }
    Get.snackbar('Signup Failed', result.message);
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
        await _notificationsService.syncSavedFcmTokenOnLaunch();
        Get.offAll(() => BottomNavBar());
        return;
      }
      Get.snackbar('Google Auth Failed', result.message);
    } catch (_) {
      isSubmitting = false;
      update();
      Get.snackbar(
        'Google Auth Failed',
        'Unable to authenticate with Google right now.',
      );
    }
  }

  void continueWithApple() {
    Get.snackbar('Not Integrated', 'Apple Sign-In is not available.');
  }

  void openLogin() => Get.to(() => LoginScreen());

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
