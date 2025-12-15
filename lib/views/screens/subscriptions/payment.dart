import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/subscriptions/address_methord.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Accounts for rentals', 'Deposit Accounts'];

  final List<Map<String, dynamic>> rentalAccounts = [
    {
      'bankName': 'American National Bank',
      'accountNumber': 'Acc no : Pk3454  -45645 456 6',
    },
    {
      'bankName': 'Swiss Bank',
      'accountNumber': 'Acc no : Pk3454  -45645 456 6',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            children: [
              Gap(20),
              // Header
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                  Gap(12),
                  MyText(
                    text: "Payment Methods",
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
              Gap(24),

              // Custom Tabs
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kPrimaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: MyText(
                              text: _tabs[index],
                              size: 14,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? kPrimaryColor
                                  : Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Gap(24),

              // Payment accounts list
              Expanded(
                child: ListView.builder(
                  itemCount: rentalAccounts.length,
                  itemBuilder: (context, index) {
                    final account = rentalAccounts[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: account['bankName'],
                                  size: 16,
                                  weight: FontWeight.w600,
                                ),
                                Gap(8),
                                MyText(
                                  text: account['accountNumber'],
                                  size: 14,
                                  color: kSubText,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Bounce(
                                onTap: () {
                                  // Delete account
                                },
                                child: CommonImageView(
                                  imagePath: Assets.imagesTrashNew,
                                  height: 50,
                                ),
                              ),
                              Gap(8),
                              Bounce(
                                onTap: () {
                                  Get.to(() => AddPaymentMethodScreen());
                                },
                                child: CommonImageView(
                                  imagePath: Assets.imagesEditProfile2,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Add new payment method button
              MyButton(
                onTap: () {
                  Get.to(() => AddPaymentMethodScreen());
                },
                buttonText: "Add new payment method",
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
              ),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
