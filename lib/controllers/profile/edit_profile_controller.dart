import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class EditProfileController extends GetxController {
  EditProfileController({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  bool isSubmitting = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePhone = FocusNode();
  final FocusNode focusNodeCountry = FocusNode();
  final FocusNode focusNodeAddress = FocusNode();

  File? profilePhotoFile;
  String? profilePhotoUrl;

  bool get isBusy => isLoading || isSubmitting;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void onFieldChanged(String _) => update();

  Future<void> loadProfile() async {
    isLoading = true;
    update();

    final result = await _profileService.getProfile();

    isLoading = false;
    if (!result.success || result.profile == null) {
      update();
      return;
    }

    final profile = result.profile!;
    fullNameController.text = profile.fullName;
    emailController.text = profile.email ?? '';
    phoneController.text = profile.phone ?? '';
    countryController.text = profile.location?.province ?? '';
    addressController.text = profile.location?.city ?? '';
    profilePhotoUrl = result.profilePhoto ?? profile.profilePhoto;
    update();
  }

  Future<void> pickNewPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }
      final file = File(picked.path);
      final error = _validateImage(file.path, await file.length());
      if (error != null) {
        Get.snackbar('Invalid Image', error);
        return;
      }
      profilePhotoFile = file;
      update();
    } catch (_) {
      Get.snackbar('Photo Error', 'Unable to pick an image right now.');
    }
  }

  void removePhoto() {
    profilePhotoFile = null;
    profilePhotoUrl = null;
    update();
  }

  Future<void> submit() async {
    final name = fullNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Missing Name', 'Please enter your full name.');
      return;
    }

    isSubmitting = true;
    update();

    final names = _splitName(name);
    final updateResult = await _profileService.updateProfile(
      UpdateProfileRequest(
        firstName: names.$1,
        lastName: names.$2,
        phone: phoneController.text.trim(),
        language: 'en',
        location: ProfileLocation(
          city: addressController.text.trim(),
          province: countryController.text.trim(),
        ),
      ),
    );

    if (!updateResult.success) {
      isSubmitting = false;
      update();
      Get.snackbar('Update Failed', updateResult.message);
      return;
    }

    if (profilePhotoFile != null) {
      final photoResult = await _profileService.uploadProfilePhoto(
        profilePhotoFile!,
      );
      if (!photoResult.success) {
        isSubmitting = false;
        update();
        Get.snackbar('Photo Upload Failed', photoResult.message);
        return;
      }
      profilePhotoUrl = photoResult.profilePhoto ?? profilePhotoUrl;
    }

    isSubmitting = false;
    update();
    Get.snackbar('Updated', 'Profile information updated successfully.');
  }

  String? _validateImage(String path, int bytes) {
    const maxBytes = 5 * 1024 * 1024;
    if (bytes > maxBytes) {
      return 'File must be 5MB or smaller.';
    }
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return null;
    }
    return 'Only JPEG, PNG, or WebP are supported.';
  }

  (String firstName, String lastName) _splitName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((element) => element.trim().isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return ('', '');
    }
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    addressController.dispose();
    focusNodeName.dispose();
    focusNodeEmail.dispose();
    focusNodePhone.dispose();
    focusNodeCountry.dispose();
    focusNodeAddress.dispose();
    super.onClose();
  }
}
