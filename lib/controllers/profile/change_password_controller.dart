import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/auth/auth_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/auth_validators.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  final TextEditingController currentCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isSubmitting = false;

  bool get isFormValid =>
      currentCtrl.text.trim().isNotEmpty &&
      newCtrl.text.trim().isNotEmpty &&
      confirmCtrl.text.trim().isNotEmpty &&
      !isSubmitting;

  bool get isPasswordStrong =>
      AuthValidators.isStrongPassword(newCtrl.text.trim());

  bool get isPasswordMatch =>
      confirmCtrl.text.trim().isNotEmpty &&
      confirmCtrl.text.trim() == newCtrl.text.trim();

  void onCurrentChanged(String _) => update();
  void onNewChanged(String _) => update();
  void onConfirmChanged(String _) => update();

  void toggleObscureCurrent() {
    obscureCurrent = !obscureCurrent;
    update();
  }

  void toggleObscureNew() {
    obscureNew = !obscureNew;
    update();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    update();
  }

  Future<void> submit() async {
    if (!isFormValid) return;

    final current = currentCtrl.text.trim();
    final newPass = newCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (!AuthValidators.isStrongPassword(newPass)) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 8 characters with uppercase, lowercase, and a number.',
      );
      return;
    }

    if (newPass != confirm) {
      Get.snackbar(
        'Mismatch',
        'New password and confirm password do not match.',
      );
      return;
    }

    if (newPass == current) {
      Get.snackbar(
        'No Change',
        'New password must be different from the current password.',
      );
      return;
    }

    isSubmitting = true;
    update();

    final result = await _authService.changePassword(
      UpdatePasswordRequest(currentPassword: current, newPassword: newPass),
    );

    isSubmitting = false;
    update();

    if (result.success) {
      Get.back();
      Get.snackbar('Success', result.message);
      return;
    }

    Get.snackbar('Update Failed', result.message);
  }

  @override
  void onClose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
