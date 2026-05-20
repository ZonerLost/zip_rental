// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/profile/change_password_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      builder: (controller) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: kbackground,
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyButton(
                    onTap: controller.submit,
                    height: 60,
                    buttonText: controller.isSubmitting
                        ? 'Updating...'
                        : 'Update',
                    backgroundColor: controller.isFormValid
                        ? kPrimaryColor
                        : kPrimaryColor2,
                    fontColor: kWhite,
                    radius: 30,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    isactive: controller.isFormValid,
                  ),
                  Gap(40),
                ],
              ),
            ),
            body: ListView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Gap(50),
                Row(
                  children: [
                    Bounce(
                      onTap: Get.back,
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 50,
                      ),
                    ),
                    Gap(10),
                    MyText(
                      text: 'Change Password',
                      size: 18,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                Gap(40),

                // Current Password
                _PasswordField(
                  label: 'Current Password',
                  hint: 'Current Password',
                  controller: controller.currentCtrl,
                  obscure: controller.obscureCurrent,
                  onToggle: controller.toggleObscureCurrent,
                  onChanged: controller.onCurrentChanged,
                ),
                Gap(20),

                // New Password
                _PasswordField(
                  label: 'Create new password',
                  hint: 'Create new password',
                  controller: controller.newCtrl,
                  obscure: controller.obscureNew,
                  onToggle: controller.toggleObscureNew,
                  onChanged: controller.onNewChanged,
                  trailingStatus: controller.newCtrl.text.trim().isNotEmpty
                      ? controller.isPasswordStrong
                      : null,
                ),
                Gap(20),

                // Confirm Password
                _PasswordField(
                  label: 'Confirm new password',
                  hint: 'Confirm new password',
                  controller: controller.confirmCtrl,
                  obscure: controller.obscureConfirm,
                  onToggle: controller.toggleObscureConfirm,
                  onChanged: controller.onConfirmChanged,
                  trailingStatus: controller.confirmCtrl.text.trim().isNotEmpty
                      ? controller.isPasswordMatch
                      : null,
                ),
                Gap(160),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.onChanged,
    this.trailingStatus,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;

  /// null = no status icon, true = green check, false = red cross
  final bool? trailingStatus;

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      label: label,
      labelColor: kSubText2,
      hint: hint,
      hintColor: kBlack.withOpacity(0.4),
      controller: controller,
      radius: 25,
      isObSecure: obscure,
      onChanged: onChanged,
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: trailingStatus!
                  ? Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 22,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
