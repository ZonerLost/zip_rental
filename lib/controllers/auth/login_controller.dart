import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_dummy_service.dart';
import 'package:zip_peer/views/screens/auth/forgot_password.dart';
import 'package:zip_peer/views/screens/auth/signup.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';

class LoginController extends GetxController {
  LoginController({AuthDummyService? authService})
    : _authService = authService ?? AuthDummyService();

  final AuthDummyService _authService;

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

    isSubmitting = true;
    update();

    final result = await _authService.login(
      LoginRequest(
        method: selectedTabIndex == 0 ? AuthMethod.email : AuthMethod.phone,
        identifier: identifierController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );

    isSubmitting = false;
    update();

    if (result.success) {
      Get.to(() => BottomNavBar());
      return;
    }
    Get.snackbar('Login Failed', result.message);
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
