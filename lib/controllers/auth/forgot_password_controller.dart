import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/auth_validators.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  final FocusNode emailFocus = FocusNode();
  final TextEditingController emailController = TextEditingController();
  bool isSubmitting = false;

  bool get isButtonActive =>
      emailController.text.trim().isNotEmpty && !isSubmitting;

  void onEmailChanged(String _) => update();

  Future<void> sendVerificationLink() {
    if (!isButtonActive) {
      return Future.value();
    }

    final email = emailController.text.trim();
    if (!AuthValidators.isValidEmail(email)) {
      Get.snackbar('Invalid Email', 'Please enter a valid email address.');
      return Future.value();
    }

    isSubmitting = true;
    update();

    return _authService
        .forgotPassword(ForgotPasswordRequest(email: email))
        .then((result) {
          isSubmitting = false;
          update();

          if (result.success) {
            emailSendBottomSheet();
            return;
          }
          Get.snackbar('Request Failed', result.message);
        });
  }

  @override
  void onClose() {
    emailFocus.dispose();
    emailController.dispose();
    super.onClose();
  }
}
