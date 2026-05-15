import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/auth_validators.dart';
import 'package:zip_peer/views/screens/auth/forgot_password.dart';
import 'package:zip_peer/views/screens/auth/otp.dart';
import 'package:zip_peer/views/screens/auth/signup.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';

class LoginController extends GetxController {
  LoginController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode identifierFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final List<String> tabs = const ['Email address', 'Phone Number'];
  int selectedTabIndex = 0;
  bool isSubmitting = false;

  String get firstHint =>
      selectedTabIndex == 0 ? 'Email address' : 'Phone Number';
  String get firstIcon =>
      selectedTabIndex == 0 ? Assets.imagesMsg : Assets.imagesCall;
  bool get isButtonActive =>
      identifierController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty &&
      !isSubmitting;

  void selectTab(int index) {
    if (selectedTabIndex == index) {
      return;
    }
    selectedTabIndex = index;
    identifierController.clear();
    update();
  }

  void onIdentifierChanged(String _) => update();

  void onPasswordChanged(String _) => update();

  Future<void> submit() async {
    if (!isButtonActive) {
      return;
    }
    if (selectedTabIndex == 1) {
      Get.snackbar(
        'Unsupported',
        'Phone login is not available in API 1.4. Use email login.',
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
      Get.to(() => BottomNavBar());
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

  Future<void> continueWithGoogle() async {
    final tokenInputController = TextEditingController();
    final proceed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Google Sign-In'),
        content: TextField(
          controller: tokenInputController,
          decoration: const InputDecoration(hintText: 'Paste Google idToken'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    final idToken = tokenInputController.text.trim();
    tokenInputController.dispose();

    if (proceed != true) {
      return;
    }
    if (idToken.isEmpty) {
      Get.snackbar('Missing Token', 'Google idToken is required.');
      return;
    }

    isSubmitting = true;
    update();

    final result = await _authService.googleAuth(
      GoogleAuthRequest(idToken: idToken, language: 'en'),
    );

    isSubmitting = false;
    update();

    if (result.success) {
      Get.offAll(() => BottomNavBar());
      return;
    }

    Get.snackbar('Google Sign-In Failed', result.message);
  }

  void continueWithApple() {
    Get.snackbar(
      'Not Integrated',
      'Apple Sign-In endpoint is not available in auth module flow.',
    );
  }

  void openForgotPassword() => Get.to(() => ForgotPasswordScreen());

  void openSignup() => Get.to(() => SignUpScreen());

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    identifierFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
