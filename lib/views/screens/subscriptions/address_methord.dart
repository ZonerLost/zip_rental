import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController holderNameController = TextEditingController(
    text: 'Christopher Henry',
  );
  final TextEditingController accountNumberController = TextEditingController(
    text: 'Pk34534 45645 456',
  );
  final TextEditingController vatNumberController = TextEditingController(
    text: '101223',
  );
  final TextEditingController zipCodeController = TextEditingController(
    text: '101223',
  );

  final FocusNode bankNameFocus = FocusNode();
  final FocusNode holderNameFocus = FocusNode();
  final FocusNode accountNumberFocus = FocusNode();
  final FocusNode vatNumberFocus = FocusNode();
  final FocusNode zipCodeFocus = FocusNode();

  String selectedBank = 'American National Bank';
  final List<String> banks = [
    'American National Bank',
    'Swiss Bank',
    'Chase Bank',
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
                  MyText(
                    text: "Add new payment method",
                    size: 16,
                    weight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ],
              ),
              Gap(32),

              // Title
              Gap(24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Bank Dropdown
                      MyText(
                        text: 'Select Bank',
                        size: 14,
                        color: kSubText,
                        paddingBottom: 8,
                      ),
                      CustomDropDown(
                        hint: 'Select Bank',
                        items: banks,
                        selectedValue: selectedBank,
                        onChanged: (value) {
                          setState(() => selectedBank = value);
                        },
                        bgColor: Colors.white,
                        labelText: "",
                      ),
           

                      // Bank holder name
                      MyTextField(
                        label: "Bank holder name",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: "Bank holder name",
                        hintColor: kBlack,
                        controller: holderNameController,
                        alwaysShowLabel: true,
                        focusNode: holderNameFocus,
                        radius: 12,
                      ),
          

                      // Account number
                      MyTextField(
                        label: "Account number",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        backgroundColor: kWhite,
                        hint: "Account number",
                        hintColor: kBlack,
                        controller: accountNumberController,
                        alwaysShowLabel: true,
                        focusNode: accountNumberFocus,
                        radius: 12,
                      ),
               
                      // VAT Number
                      MyTextField(
                        label: "Vat Number",
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: "Vat Number",
                        hintColor: kBlack,
                        controller: vatNumberController,
                        alwaysShowLabel: true,
                        focusNode: vatNumberFocus,
                        radius: 12,
                      ),
             

                      // Zip Code
                      MyTextField(
                        label: "Zip Code",
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
