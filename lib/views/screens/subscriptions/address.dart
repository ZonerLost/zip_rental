import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/subscriptions/add_address.dart';
import 'package:zip_peer/views/screens/subscriptions/payment.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final List<Map<String, dynamic>> addresses = [
    {
      'title': 'Home Address',
      'address': 'St3, Wilson road, Brooklyn, USA 10121',
    },
    {
      'title': 'Office Address',
      'address': 'St3, Wilson road, Brooklyn, USA 10121',
    },
    {
      'title': 'Friends Address',
      'address': 'St3, Wilson road, Brooklyn, USA 10121',
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
                    text: "My Addresses",
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
              Gap(24),

              // Addresses list
              Expanded(
                child: ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
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
                                  text: address['title'],
                                  size: 18,
                                  weight: FontWeight.w600,
                                ),
                                Gap(8),
                                MyText(
                                  text: address['address'],
                                  size: 14,
                                  color: kSubText,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Bounce(
                                onTap: () {
                                  // Delete address
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Gap(8),
                              Bounce(
                                onTap: () {
                                  Get.to(() => AddAddressScreen());
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    color: kPrimaryColor,
                                    size: 24,
                                  ),
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

              // Add new address button
              MyButton(
                onTap: () {
                  Get.to(() => AddAddressScreen());
                },
                buttonText: "Add new address",
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
