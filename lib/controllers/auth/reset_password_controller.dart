import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/auth_validators.dart';
import 'package:zip_peer/views/screens/auth/login.dart';

class ResetPasswordController extends GetxController {
  ResetPasswordController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  final FocusNode otpFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String pendingEmail = '';
  bool isSubmitting = false;

  @override
  void onInit() {
    super.onInit();
    _loadPendingEmail();
  }

  Future<void> _loadPendingEmail() async {
    pendingEmail = await _authService.getPendingEmail() ?? '';
    update();
  }

  bool get isButtonActive =>
      otpController.text.trim().length == 6 &&
      passwordController.text.trim().isNotEmpty &&
      confirmPasswordController.text.trim().isNotEmpty &&
      passwordController.text.trim() == confirmPasswordController.text.trim() &&
      !isSubmitting;

  void onOtpChanged(String _) => update();

  void onPasswordChanged(String _) => update();

  void onConfirmPasswordChanged(String _) => update();

  Future<void> submit() async {
    if (!isButtonActive) {
      return;
    }

    final newPassword = passwordController.text.trim();
    if (!AuthValidators.isStrongPassword(newPassword)) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 8 characters and include an uppercase letter and a number.',
      );
      return;
    }

    isSubmitting = true;
    update();

    if (pendingEmail.isEmpty) {
      isSubmitting = false;
      update();
      Get.snackbar('Missing Email', 'Please request password reset again.');
      return;
    }

    final result = await _authService.resetPassword(
      ResetPasswordRequest(
        email: pendingEmail,
        otp: otpController.text.trim(),
        newPassword: newPassword,
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
    otpFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
