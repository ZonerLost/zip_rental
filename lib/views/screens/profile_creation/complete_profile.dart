import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/profile_creation_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class CompleteYourProfileScreen extends StatelessWidget {
  const CompleteYourProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileCreationController>(
      init: ProfileCreationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyButton(
                  buttonText: controller.primaryButtonText,
                  onTap: controller.handlePrimaryAction,
                  height: 60,
                  radius: 30,
                  fontColor: Colors.white,
                  fontSize: 18,
                  hasgrad: false,
                  backgroundColor: controller.isPrimaryButtonActive
                      ? kPrimaryColor
                      : kPrimaryColor2,
                ),
                const Gap(40),
              ],
            ),
          ),
          body: Column(
            children: [
              const Gap(100),
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: controller.onPageChanged,
                  children: [
                    _buildStep1(controller),
                    _buildStep2(controller),
                    _buildStep3(controller),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1(ProfileCreationController controller) {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              text: 'Step 1/3',
              size: 14,
              weight: FontWeight.w500,
              color: kSubText2,
            ),
            const Gap(12),
            const MyText(
              text: 'Complete your Profile',
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black,
            ),
            const Gap(8),
            const MyText(
              text:
                  'Please enter your personal information to get things started.',
              size: 14,
              weight: FontWeight.w400,
              color: kSubText2,
            ),
            const Gap(40),
            Center(
              child: Bounce(
                onTap: controller.openProfilePhotoPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (controller.profilePhotoFile != null)
                        CommonImageView(
                          file: controller.profilePhotoFile,
                          height: 100,
                          width: 100,
                          radius: 50,
                        )
                      else if ((controller.profilePhotoUrl ?? '').isNotEmpty)
                        CommonImageView(
                          url: controller.profilePhotoUrl,
                          height: 100,
                          width: 100,
                          radius: 50,
                        )
                      else
                        CommonImageView(
                          imagePath: Assets.imagesPersonIcon,
                          height: 100,
                        ),
                      const Gap(12),
                      const MyText(
                        text: 'Upload Profile Photo',
                        size: 20,
                        weight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(40),
            const MyText(
              text: 'CONTACT INFORMATION',
              size: 12,
              weight: FontWeight.w600,
              color: kSubText2,
              letterSpacing: 1,
            ),
            const Gap(20),
            MyTextField(
              hint: 'Full Name',
              hintColor: kBlack,
              controller: controller.nameController,
              focusNode: controller.nameFocus,
              radius: 12,
              marginBottom: 16,
              onChanged: controller.onFieldChanged,
            ),
            MyTextField(
              hint: 'Email address',
              hintColor: kBlack,
              controller: controller.emailController,
              focusNode: controller.emailFocus,
              radius: 12,
              marginBottom: 16,
              isReadOnly: true,
              onChanged: controller.onFieldChanged,
            ),
            MyTextField(
              hint: 'Phone number',
              hintColor: kBlack,
              controller: controller.phoneController,
              focusNode: controller.phoneFocus,
              radius: 12,
              marginBottom: 16,
              keyboardType: TextInputType.phone,
              onChanged: controller.onFieldChanged,
            ),
            const Gap(40),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2(ProfileCreationController controller) {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText(
              text: 'Step 2/3',
              size: 14,
              weight: FontWeight.w500,
              color: kSubText2,
            ),
            const Gap(12),
            const MyText(
              text: 'Verify your Identity',
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black,
            ),
            const Gap(8),
            const MyText(
              text:
                  'Please upload your national ID here to verify your identity.',
              size: 14,
              weight: FontWeight.w400,
              color: kSubText2,
            ),
            const Gap(200),
            Center(
              child: Bounce(
                onTap: controller.openIdentityDocumentPicker,
                child: Column(
                  children: [
                    CommonImageView(imagePath: Assets.imagesIdCard, height: 80),
                    const Gap(30),
                    const MyText(
                      text: 'ID Verification',
                      size: 20,
                      weight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const Gap(12),
                    MyText(
                      text: controller.identityDocumentFile == null
                          ? 'Please upload your national ID here to\nverify your identity.'
                          : 'Selected: ${controller.identityDocumentFile!.path.split('\\').last}',
                      size: 14,
                      weight: FontWeight.w400,
                      color: kSubText2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(80),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3(ProfileCreationController controller) {
    return AnimatedListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              text: 'Step 3/3',
              size: 14,
              weight: FontWeight.w500,
              color: kSubText2,
            ),
            const Gap(8),
            const MyText(
              text: 'Add Address',
              size: 24,
              weight: FontWeight.w700,
              color: Colors.black,
            ),
            const Gap(8),
            const MyText(
              text:
                  'Please enter your address that will be used for delivery of items.',
              size: 14,
              weight: FontWeight.w400,
              color: kSubText2,
            ),
            const Gap(30),
            MyTextField(
              label: 'Address Title',
              labelColor: kSubText,
              hint: 'Home Address',
              labelWeight: FontWeight.w400,
              labelSize: 12,
              hintColor: kBlack,
              controller: controller.addressTitleController,
              focusNode: controller.addressTitleFocus,
              radius: 12,
              onChanged: controller.onFieldChanged,
            ),
            MyTextField(
              hint: 'City',
              label: 'City',
              labelWeight: FontWeight.w400,
              labelSize: 12,
              labelColor: kSubText,
              hintColor: kBlack,
              controller: controller.streetController,
              focusNode: controller.streetFocus,
              radius: 12,
              onChanged: controller.onFieldChanged,
            ),
            CustomDropDown(
              hint: 'Select Country',
              items: controller.countries,
              selectedValue: controller.selectedCountry,
              onChanged: (value) => controller.onCountryChanged(value),
              bgColor: Colors.white,
              labelText: null,
            ),
            MyTextField(
              hint: '101223',
              label: 'Zip Code',
              labelWeight: FontWeight.w400,
              labelSize: 12,
              labelColor: kSubText,
              hintColor: kBlack,
              controller: controller.zipCodeController,
              focusNode: controller.zipCodeFocus,
              radius: 12,
              onChanged: controller.onFieldChanged,
            ),
            MyTextField(
              hint: 'Street and full address details',
              hintColor: kBlack,
              labelWeight: FontWeight.w400,
              labelSize: 12,
              label: 'Complete Address',
              labelColor: kSubText,
              maxLines: 4,
              controller: controller.completeAddressController,
              focusNode: controller.completeAddressFocus,
              radius: 12,
              onChanged: controller.onFieldChanged,
            ),
          ],
        ),
      ],
    );
  }
}
