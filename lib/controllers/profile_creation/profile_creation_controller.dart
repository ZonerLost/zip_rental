import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/profile/profile_service.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';

class ProfileCreationController extends GetxController {
  ProfileCreationController({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;
  final ImagePicker _imagePicker = ImagePicker();
  final PageController pageController = PageController();

  int currentStep = 0;
  bool isLoadingProfile = false;
  bool isSubmitting = false;

  File? profilePhotoFile;
  String? profilePhotoUrl;
  File? identityDocumentFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressTitleController = TextEditingController(
    text: 'Home Address',
  );
  final TextEditingController streetController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController completeAddressController =
      TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressTitleFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();
  final FocusNode zipCodeFocus = FocusNode();
  final FocusNode completeAddressFocus = FocusNode();

  final List<String> countries = <String>[
    'United States of America',
    'Pakistan',
    'United Kingdom',
    'Canada',
    'Australia',
  ];
  String selectedCountry = 'United States of America';

  bool get isBusy => isLoadingProfile || isSubmitting;

  bool get isPrimaryButtonActive {
    if (isBusy) {
      return false;
    }
    switch (currentStep) {
      case 0:
        return nameController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty;
      case 1:
        return identityDocumentFile != null;
      case 2:
        return streetController.text.trim().isNotEmpty &&
            completeAddressController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  String get primaryButtonText {
    if (isBusy) {
      return 'Please wait...';
    }
    switch (currentStep) {
      case 0:
        return 'Continue';
      case 1:
        return 'Upload';
      case 2:
        return 'Confirm';
      default:
        return 'Continue';
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoadingProfile = true;
    update();

    final result = await _profileService.getProfile();

    isLoadingProfile = false;
    if (!result.success || result.profile == null) {
      update();
      return;
    }

    final profile = result.profile!;
    if (profile.fullName.isNotEmpty) {
      nameController.text = profile.fullName;
    }
    if ((profile.email ?? '').isNotEmpty) {
      emailController.text = profile.email!.trim();
    }
    if ((profile.phone ?? '').isNotEmpty) {
      phoneController.text = profile.phone!.trim();
    }
    final city = profile.location?.city?.trim() ?? '';
    final province = profile.location?.province?.trim() ?? '';
    if (city.isNotEmpty) {
      streetController.text = city;
      completeAddressController.text = city;
    }
    if (province.isNotEmpty) {
      selectedCountry = province;
      if (!countries.contains(province)) {
        countries.add(province);
      }
    }
    profilePhotoUrl = result.profilePhoto ?? profile.profilePhoto;
    update();
  }

  void onFieldChanged(String _) => update();

  void onPageChanged(int index) {
    currentStep = index;
    update();
  }

  void onCountryChanged(String value) {
    selectedCountry = value;
    update();
  }

  Future<void> openProfilePhotoPicker() async {
    final file = await _pickImage(
      source: ImageSource.gallery,
      errorPrefix: 'Profile Photo',
    );
    if (file == null) {
      return;
    }
    profilePhotoFile = file;
    update();
  }

  Future<void> openIdentityDocumentPicker() async {
    final file = await _pickImage(
      source: ImageSource.gallery,
      errorPrefix: 'Identity Document',
    );
    if (file == null) {
      return;
    }
    identityDocumentFile = file;
    update();
  }

  Future<void> handlePrimaryAction() async {
    if (!isPrimaryButtonActive || isBusy) {
      return;
    }
    switch (currentStep) {
      case 0:
        await _submitStepOne();
        break;
      case 1:
        await _submitStepTwo();
        break;
      case 2:
        await _submitStepThree();
        break;
    }
  }

  Future<void> handleBack() async {
    if (currentStep == 0) {
      Get.back();
      return;
    }
    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitStepOne() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Missing Name', 'Please enter your full name.');
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar('Missing Phone', 'Please enter your phone number.');
      return;
    }

    final names = _splitName(name);
    isSubmitting = true;
    update();

    final updateResult = await _profileService.updateProfile(
      UpdateProfileRequest(
        firstName: names.$1,
        lastName: names.$2,
        phone: phone,
        language: 'en',
      ),
    );

    if (!updateResult.success) {
      isSubmitting = false;
      update();
      Get.snackbar('Profile Update Failed', updateResult.message);
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
    await _goToNextStep();
  }

  Future<void> _submitStepTwo() async {
    if (identityDocumentFile == null) {
      Get.snackbar(
        'Missing Document',
        'Please upload your identity document to continue.',
      );
      return;
    }

    isSubmitting = true;
    update();

    final result = await _profileService.verifyIdentity(identityDocumentFile!);

    isSubmitting = false;
    update();

    if (!result.success) {
      Get.snackbar('Verification Failed', result.message);
      return;
    }
    await _goToNextStep();
  }

  Future<void> _submitStepThree() async {
    final city = streetController.text.trim();
    final fullAddress = completeAddressController.text.trim();
    if (city.isEmpty || fullAddress.isEmpty) {
      Get.snackbar(
        'Address Required',
        'Please complete your address details before continuing.',
      );
      return;
    }

    isSubmitting = true;
    update();

    final result = await _profileService.updateProfile(
      UpdateProfileRequest(
        location: ProfileLocation(city: city, province: selectedCountry),
      ),
    );

    isSubmitting = false;
    update();

    if (!result.success) {
      Get.snackbar('Address Update Failed', result.message);
      return;
    }

    Get.offAll(() => const BottomNavBar());
  }

  Future<void> _goToNextStep() async {
    if (currentStep >= 2) {
      return;
    }
    await pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<File?> _pickImage({
    required ImageSource source,
    required String errorPrefix,
  }) async {
    try {
      final picked = await _imagePicker.pickImage(source: source);
      if (picked == null) {
        return null;
      }
      final file = File(picked.path);
      final validationError = _validateImageFile(
        file.path,
        await file.length(),
      );
      if (validationError != null) {
        Get.snackbar('$errorPrefix Error', validationError);
        return null;
      }
      return file;
    } catch (_) {
      Get.snackbar('$errorPrefix Error', 'Unable to select file right now.');
      return null;
    }
  }

  String? _validateImageFile(String path, int bytes) {
    const maxFileSize = 5 * 1024 * 1024;
    if (bytes > maxFileSize) {
      return 'File must be 5MB or smaller.';
    }

    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return null;
    }
    return 'Only JPEG, PNG, or WebP files are allowed.';
  }

  (String firstName, String lastName) _splitName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return ('', '');
    }
    if (parts.length == 1) {
      return (parts.first, '');
    }
    final first = parts.first;
    final last = parts.sublist(1).join(' ');
    return (first, last);
  }

  @override
  void onClose() {
    pageController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressTitleController.dispose();
    streetController.dispose();
    zipCodeController.dispose();
    completeAddressController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    addressTitleFocus.dispose();
    streetFocus.dispose();
    zipCodeFocus.dispose();
    completeAddressFocus.dispose();
    super.onClose();
  }
}
