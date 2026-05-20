import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/profile/edit_profile_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyButton(
                  height: 60,
                  buttonText: controller.isSubmitting
                      ? 'Updating...'
                      : 'Update',
                  onTap: controller.submit,
                  backgroundColor: kPrimaryColor,
                  fontColor: kWhite,
                  radius: 30,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  hasgrad: false,
                ),
                const Gap(50),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(50),
                  Row(
                    children: [
                      Bounce(
                        onTap: Get.back,
                        child: CommonImageView(
                          imagePath: Assets.imagesBack,
                          height: 50,
                        ),
                      ),
                      const Gap(10),
                      MyText(
                        text: 'Edit Profile',
                        size: 18,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(40),
                  Center(
                    child: Column(
                      children: [
                        if (controller.profilePhotoFile != null)
                          CommonImageView(
                            file: controller.profilePhotoFile,
                            height: 120,
                            width: 120,
                            radius: 60,
                          )
                        else if ((controller.profilePhotoUrl ?? '').isNotEmpty)
                          CommonImageView(
                            url: controller.profilePhotoUrl,
                            height: 120,
                            width: 120,
                            radius: 60,
                          )
                        else
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: kWhite3,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Center(
                              child: CommonImageView(
                                imagePath: Assets.imagesPersonIcon,
                                height: 52,
                                width: 52,
                              ),
                            ),
                          ),
                        const Gap(24),
                        MyText(
                          text: 'Upload Profile Photo',
                          size: 18,
                          color: kBlack,
                          weight: FontWeight.w500,
                        ),
                        const Gap(12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            spacing: 20,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: MyButton(
                                  buttonText: 'Remove Photo',
                                  onTap: controller.removePhoto,
                                  hasgrad: false,
                                  backgroundColor: kWhite,
                                  fontColor: kSubText2,
                                  radius: 12,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: MyButton(
                                  buttonText: 'Change Photo',
                                  onTap: controller.pickNewPhoto,
                                  hasgrad: false,
                                  backgroundColor: kPrimaryColor.withOpacity(
                                    0.2,
                                  ),
                                  fontColor: kPrimaryColor,
                                  radius: 12,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(40),
                  MyText(
                    text: 'PERSONAL INFORMATION',
                    size: 12,
                    color: kBlack.withOpacity(0.5),
                    weight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  const Gap(20),
                  if (!controller.isNameExpanded)
                    GestureDetector(
                      onTap: controller.expandName,
                      child: MyTextField(
                        label: 'Full name',
                        labelColor: kSubText2,
                        hint: 'Full Name',
                        hintColor: kBlack.withOpacity(0.4),
                        controller: TextEditingController(
                          text: controller.displayFullName,
                        ),
                        radius: 25,
                        isReadOnly: true,
                        onTap: controller.expandName,
                      ),
                    )
                  else
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Focus(
                        onFocusChange: (_) => controller.collapseNameIfEmpty(),
                        child: Column(
                          children: [
                            MyTextField(
                              label: 'First name',
                              labelColor: kSubText2,
                              hint: 'First Name',
                              hintColor: kBlack.withOpacity(0.4),
                              controller: controller.firstNameController,
                              focusNode: controller.focusNodeFirstName,
                              radius: 25,
                              onChanged: controller.onFieldChanged,
                            ),
                            MyTextField(
                              label: 'Last name',
                              labelColor: kSubText2,
                              hint: 'Last Name',
                              hintColor: kBlack.withOpacity(0.4),
                              controller: controller.lastNameController,
                              focusNode: controller.focusNodeLastName,
                              radius: 25,
                              onChanged: controller.onFieldChanged,
                            ),
                          ],
                        ),
                      ),
                    ),
                  MyTextField(
                    label: 'Email address',
                    labelColor: kSubText2,
                    hint: 'Email address',
                    hintColor: kBlack.withOpacity(0.4),
                    controller: controller.emailController,
                    focusNode: controller.focusNodeEmail,
                    radius: 25,
                    isReadOnly: true,
                    onChanged: controller.onFieldChanged,
                  ),
                  MyTextField(
                    label: 'Phone Number',
                    labelColor: kSubText2,
                    hint: '+123456789',
                    hintColor: kBlack.withOpacity(0.4),
                    controller: controller.phoneController,
                    focusNode: controller.focusNodePhone,
                    radius: 25,
                    keyboardType: TextInputType.phone,
                    onChanged: controller.onFieldChanged,
                  ),
                  MyTextField(
                    label: 'Country',
                    labelColor: kSubText2,
                    hint: 'United States of America',
                    hintColor: kBlack.withOpacity(0.4),
                    controller: controller.countryController,
                    focusNode: controller.focusNodeCountry,
                    radius: 25,
                    onChanged: controller.onFieldChanged,
                  ),
                  MyTextField(
                    maxLines: 4,
                    label: 'Address',
                    labelColor: kSubText2,
                    hint: 'City / complete address',
                    hintColor: kBlack.withOpacity(0.4),
                    controller: controller.addressController,
                    focusNode: controller.focusNodeAddress,
                    radius: 25,
                    onChanged: controller.onFieldChanged,
                  ),
                  const Gap(100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
