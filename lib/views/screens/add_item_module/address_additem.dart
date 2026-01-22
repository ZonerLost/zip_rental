import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/pickup_avalibility.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class AddressAddItemScreen extends StatefulWidget {
  const AddressAddItemScreen({super.key});

  @override
  State<AddressAddItemScreen> createState() => _AddressAddItemScreenState();
}

class _AddressAddItemScreenState extends State<AddressAddItemScreen> {
  int selectedAddressIndex = -1;
  bool _showSelectAddressError = false;

  final List<Map<String, dynamic>> addresses = [
    {
      'title': 'Home Address',
      'address': 'St3 , Wilson road , Brooklyn, 10121',
      'distance': '1.5 KM',
      'fee': '\$10.00 delivery fees',
    },
    {
      'title': 'Office Address',
      'address': 'St3 , Wilson road , Brooklyn, USA 10121',
      'distance': '10.4 KM',
      'fee': '\$45.00 delivery fees',
    },
    {
      'title': 'Friends Address',
      'address': 'St3 , Wilson road , Brooklyn, USA 10121',
      'distance': '1.5 KM',
      'fee': '\$10.00 delivery fees',
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
                if (selectedAddressIndex == -1) {
                  setState(() {
                    _showSelectAddressError = true;
                  });
                  return;
                }
                Get.to(() => PickupAvailabilityScreen());
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
                      text: "Pickup address",
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              MyText(text: "Step 2/4", size: 14, color: kSubText),
            ],
          ),
          Gap(20),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,

            physics: NeverScrollableScrollPhysics(),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              final isSelected = selectedAddressIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Bounce(
                  onTap: () {
                    setState(() {
                      // Toggle selection: if already selected, unselect it
                      if (selectedAddressIndex == index) {
                        selectedAddressIndex = -1;
                      } else {
                        selectedAddressIndex = index;
                      }
                      _showSelectAddressError = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor.withOpacity(0.2)
                          : kWhite,
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
                              text: address['title'],
                              size: 18,
                              weight: FontWeight.w600,
                              color: kBlack,
                            ),
                            if (isSelected)
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: kWhite,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        Gap(8),
                        MyText(
                          text: address['address'],
                          size: 14,
                          color: kSubText2,
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Gap(20),

          MyButton(
            onTap: () {
              Get.back();
            },
            buttonText: "+ Add New Address",
            fontColor: kPrimaryColor,
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            height: 56,
            radius: 28,
            hasicon: true,
            hasgrad: false,
            fontSize: 17,
          ),
          if (_showSelectAddressError) Gap(20),
          if (_showSelectAddressError)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: kredColor, size: 30),
                Gap(8),
                MyText(
                  text: "Please Select an Address",
                  size: 16,
                  color: kredColor,
                  weight: FontWeight.w600,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
