import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/subscriptions/address_methord.dart';
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
  final TextEditingController titleController = TextEditingController(
    text: 'Home Address',
  );
  final TextEditingController streetController = TextEditingController(
    text: 'St 4, Wilson road',
  );
  final TextEditingController zipCodeController = TextEditingController(
    text: '101223',
  );
  final TextEditingController completeAddressController = TextEditingController(
    text: 'St 4, Wilson road, house 34, Brooklyn , USA',
  );

  final FocusNode titleFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();
  final FocusNode zipCodeFocus = FocusNode();
  final FocusNode completeAddressFocus = FocusNode();

  String selectedCountry = 'United States of America';
  final List<String> countries = [
    'United States of America',
    'Canada',
    'United Kingdom',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),
              // Back Button
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                  Gap(8),
                  // Title
                  MyText(
                    text: "Add new address",
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ],
              ),

              Gap(24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Title
                      MyTextField(
                        label: "Address Title",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: "Address Title",
                        hintColor: kBlack,
                        controller: titleController,
                        alwaysShowLabel: true,
                        focusNode: titleFocus,
                        radius: 12,
                      ),

                      // Street
                      MyTextField(
                        label: "Street ",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: "Street",
                        hintColor: kBlack,
                        controller: streetController,
                        alwaysShowLabel: true,
                        focusNode: streetFocus,
                        radius: 12,
                      ),

                      // Country Dropdown
                      MyText(
                        text: 'Country',
                        size: 14,
                        color: kBlack,
                        paddingBottom: 8,
                      ),
                      CustomDropDown(
                        hint: 'Select Country',
                        items: countries,
                        selectedValue: selectedCountry,
                        onChanged: (value) {
                          setState(() => selectedCountry = value);
                        },
                        bgColor: Colors.white,
                        labelText: "",
                      ),
                      // Zip Code
                      MyTextField(
                        label: "Zip Code ",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: "Zip Code",
                        hintColor: kBlack,
                        controller: zipCodeController,
                        alwaysShowLabel: true,
                        focusNode: zipCodeFocus,
                        radius: 12,
                      ),

                      // Complete Address
                      MyTextField(
                        label: "Complete Address",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: "Complete Address",
                        hintColor: kBlack,
                        controller: completeAddressController,
                        alwaysShowLabel: true,
                        focusNode: completeAddressFocus,
                        radius: 12,
                        maxLines: 4,
                      ),
                      Gap(32),
                    ],
                  ),
                ),
              ),

              // Add Button
              MyButton(
                onTap: () {
                  Get.back();
                },
                buttonText: "Add",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
