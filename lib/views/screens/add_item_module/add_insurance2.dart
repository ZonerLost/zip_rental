import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/bosst.dart';
import 'package:zip_peer/views/screens/home/item_detail/check_out.dart';
import 'package:zip_peer/views/screens/home/item_detail/check_out_2.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class AddInsuranceScreen2 extends StatefulWidget {
  const AddInsuranceScreen2({super.key});

  @override
  State<AddInsuranceScreen2> createState() => _AddInsuranceScreen2State();
}

class _AddInsuranceScreen2State extends State<AddInsuranceScreen2> {
  int selectedInsuranceIndex = 0;

  final List<Map<String, dynamic>> insuranceOptions = [
    {
      'title': 'No Insurance',
      'description': '',
      'price': '\$0',
      'isSelected': false,
    },
    {
      'title': 'Standard Protection',
      'description': 'Essential coverage for minor damages and everyday wear.',
      'price': '\$10',
      'isSelected': false,
    },
    {
      'title': 'Premium Protection',
      'description':
          'Comprehensive coverage for theft, damage and liability during rentals or transfer.',
      'price': '\$10',
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyButton(
              onTap: () {
                Get.to(() => CheckoutScreen());
              },
              buttonText: "Continue",
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

      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Gap(50),
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bounce(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    CommonImageView(imagePath: Assets.imagesBack, height: 40),
                    Gap(8),
                    MyText(
                      text: "Add Insurance",
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              MyText(text: "Step 3/4", size: 14, color: kSubText),
            ],
          ),
          Gap(20),

          Column(
            children: List.generate(insuranceOptions.length, (index) {
              final option = insuranceOptions[index];
              final isSelected = selectedInsuranceIndex == index;

              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Bounce(
                  onTap: () {
                    setState(() {
                      selectedInsuranceIndex = index;
                    });
                  },
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: option['title'],
                              size: 18,
                              weight: FontWeight.w600,
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: kWhite,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        Gap(8),
                        (option['description'] as String).isNotEmpty
                            ? MyText(
                                text: option['description'],
                                size: 14,
                                color: kSubText,
                              )
                            : const SizedBox.shrink(),

                        (option['description'] as String).isNotEmpty
                            ? Gap(16)
                            : const SizedBox.shrink(),
                        MyText(
                          text: option['price'],
                          size: 24,
                          weight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          Gap(100),
        ],
      ),
    );
  }
}
