import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_dummy_service.dart';
import 'package:zip_peer/views/screens/auth/login.dart';

class ResetPasswordController extends GetxController {
  ResetPasswordController({AuthDummyService? authService})
    : _authService = authService ?? AuthDummyService();

  final AuthDummyService _authService;

  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isSubmitting = false;

  bool get isButtonActive =>
      passwordController.text.trim().isNotEmpty &&
      confirmPasswordController.text.trim().isNotEmpty &&
      passwordController.text.trim() == confirmPasswordController.text.trim() &&
      !isSubmitting;

  void onPasswordChanged(String _) => update();

  void onConfirmPasswordChanged(String _) => update();

  Future<void> submit() async {
    if (!isButtonActive) {
      return;
    }

    isSubmitting = true;
    update();

    final result = await _authService.resetPassword(
      ResetPasswordRequest(
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      ),
    );

    isSubmitting = false;
    update();

    if (result.success) {
      Get.offAll(() => LoginScreen());
      return;
    }
    Get.snackbar('Reset Failed', result.message);
  }

  @override
  void onClose() {
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
