import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/profile/address_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _labelController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _selectedCountry = 'Canada';
  final List<String> _countries = ['Canada', 'United States of America', 'United Kingdom'];

  bool _showError = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  bool _validate() {
    final ok = _labelController.text.trim().isNotEmpty &&
        _addressLineController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _postalCodeController.text.trim().isNotEmpty;
    if (!ok) setState(() => _showError = true);
    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isSaving = true);

    final request = AddAddressRequest(
      label: _labelController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim(),
      country: _selectedCountry,
      postalCode: _postalCodeController.text.trim(),
    );

    AddressController? controller;
    try {
      controller = Get.find<AddressController>();
    } catch (_) {
      controller = null;
    }

    bool success;
    if (controller != null) {
      success = await controller.addAddress(request);
    } else {
      // AddressController not in scope — create a temporary one just for the call
      final temp = AddressController();
      success = await temp.addAddress(request);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: CommonImageView(imagePath: Assets.imagesBack, height: 50),
                  ),
                  const Gap(8),
                  const MyText(text: 'Add new address', size: 16, weight: FontWeight.w700),
                ],
              ),
              const Gap(24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(
                        label: 'Address Label *',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. Home, Office',
                        hintColor: kBlack,
                        controller: _labelController,
                        alwaysShowLabel: true,
                        radius: 12,
                        onChanged: (_) => setState(() => _showError = false),
                      ),
                      MyTextField(
                        label: 'Street Address *',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. 123 Main St',
                        hintColor: kBlack,
                        controller: _addressLineController,
                        alwaysShowLabel: true,
                        radius: 12,
                        onChanged: (_) => setState(() => _showError = false),
                      ),
                      MyTextField(
                        label: 'City *',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. Toronto',
                        hintColor: kBlack,
                        controller: _cityController,
                        alwaysShowLabel: true,
                        radius: 12,
                        onChanged: (_) => setState(() => _showError = false),
                      ),
                      MyTextField(
                        label: 'Province / State',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. ON',
                        hintColor: kBlack,
                        controller: _provinceController,
                        alwaysShowLabel: true,
                        radius: 12,
                      ),
                      const MyText(text: 'Country', size: 12, color: kSubText, paddingBottom: 8),
                      CustomDropDown(
                        hint: 'Select Country',
                        items: _countries,
                        selectedValue: _selectedCountry,
                        onChanged: (value) => setState(() => _selectedCountry = value),
                        bgColor: Colors.white,
                        labelText: '',
                      ),
                      const Gap(16),
                      MyTextField(
                        label: 'Postal / Zip Code *',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. M5V 1A1',
                        hintColor: kBlack,
                        controller: _postalCodeController,
                        alwaysShowLabel: true,
                        radius: 12,
                        onChanged: (_) => setState(() => _showError = false),
                      ),
                      if (_showError) ...[
                        const Gap(8),
                        const Row(
                          children: [
                            Icon(Icons.error_outline, color: kredColor, size: 16),
                            Gap(6),
                            MyText(text: 'Please fill in all required fields.', size: 13, color: kredColor),
                          ],
                        ),
                      ],
                      const Gap(32),
                    ],
                  ),
                ),
              ),
              MyButton(
                onTap: () { if (!_isSaving) _submit(); },
                buttonText: _isSaving ? 'Saving...' : 'Add Address',
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
