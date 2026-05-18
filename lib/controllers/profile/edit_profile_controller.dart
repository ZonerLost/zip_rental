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
  bool isNameExpanded = false;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FocusNode focusNodeFirstName = FocusNode();
  final FocusNode focusNodeLastName = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePhone = FocusNode();
  final FocusNode focusNodeCountry = FocusNode();
  final FocusNode focusNodeAddress = FocusNode();

  File? profilePhotoFile;
  String? profilePhotoUrl;

  bool get isBusy => isLoading || isSubmitting;

  String get displayFullName {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    return [first, last].where((s) => s.isNotEmpty).join(' ');
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void onFieldChanged(String _) => update();

  void expandName() {
    isNameExpanded = true;
    update();
    Future.delayed(const Duration(milliseconds: 50), () {
      focusNodeFirstName.requestFocus();
    });
  }

  void collapseNameIfEmpty() {
    if (!focusNodeFirstName.hasFocus && !focusNodeLastName.hasFocus) {
      isNameExpanded = false;
      update();
    }
  }

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
    firstNameController.text = profile.firstName ?? '';
    lastNameController.text = profile.lastName ?? '';
    emailController.text = profile.email ?? '';
    phoneController.text = profile.phone ?? '';
    countryController.text =
        profile.location?.country ?? profile.location?.province ?? '';
    addressController.text = profile.location?.city ?? '';
    profilePhotoUrl = _withCacheBust(
      result.profilePhoto ?? profile.profilePhoto,
      profile.updatedAt,
    );
    update();
  }

  Future<void> pickNewPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
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
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    if (firstName.isEmpty) {
      Get.snackbar('Missing Name', 'Please enter your first name.');
      return;
    }
    if (lastName.isEmpty) {
      Get.snackbar('Missing Name', 'Please enter your last name.');
      return;
    }

    isSubmitting = true;
    update();

    final updateResult = await _profileService.updateProfile(
      UpdateProfileRequest(
        firstName: firstName,
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        language: 'en',
        location: ProfileLocation(
          country: countryController.text.trim(),
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
      profilePhotoUrl = _withCacheBust(
        photoResult.profilePhoto ?? profilePhotoUrl,
        photoResult.profile?.updatedAt,
      );
      await _refreshProfilePhotoFromServer();
      profilePhotoFile = null;
    }

    isSubmitting = false;
    update();
    Get.back();
    Get.snackbar('Updated', 'Profile information updated successfully.');
  }

  String? _validateImage(String path, int bytes) {
    const maxBytes = 5 * 1024 * 1024;
    if (bytes > maxBytes) return 'File must be 5MB or smaller.';
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return null;
    }
    return 'Only JPEG, PNG, or WebP are supported.';
  }

  Future<void> _refreshProfilePhotoFromServer() async {
    final latestResult = await _profileService.getProfile();
    if (!latestResult.success || latestResult.profile == null) return;
    final latestProfile = latestResult.profile!;
    profilePhotoUrl = _withCacheBust(
      latestResult.profilePhoto ?? latestProfile.profilePhoto,
      latestProfile.updatedAt,
    );
  }

  String? _withCacheBust(String? url, DateTime? updatedAt) {
    final value = (url ?? '').trim();
    if (value.isEmpty) return null;
    if (updatedAt == null) return value;
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    final query = Map<String, String>.from(uri.queryParameters);
    query['v'] = updatedAt.millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: query).toString();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    addressController.dispose();
    focusNodeFirstName.dispose();
    focusNodeLastName.dispose();
    focusNodeEmail.dispose();
    focusNodePhone.dispose();
    focusNodeCountry.dispose();
    focusNodeAddress.dispose();
    super.onClose();
  }
}
