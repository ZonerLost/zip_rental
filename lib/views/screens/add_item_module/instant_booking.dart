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

class InstantBookingOptionsScreen extends StatefulWidget {
  const InstantBookingOptionsScreen({super.key});

  @override
  State<InstantBookingOptionsScreen> createState() =>
      _InstantBookingOptionsScreenState();
}

class _InstantBookingOptionsScreenState
    extends State<InstantBookingOptionsScreen> {
  int? _selectedOption; // 0 = recurring, 1 = specific dates
  bool _showError = false;
  String bookingType = 'instant';
  String rentalType = 'delivery';

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['bookingType'] != null) {
        bookingType = Get.arguments['bookingType'];
      }
      if (Get.arguments['rentalType'] != null) {
        rentalType = Get.arguments['rentalType'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              onTap: () {
                if (_selectedOption == null) {
                  setState(() {
                    _showError = true;
                  });
                  return;
                }

                // Navigate to Pickup Availability with schedule type
                Get.to(
                  () => PickupAvailabilityScreen(),
                  arguments: {
                    'bookingType': bookingType,
                    'rentalType': rentalType,
                    'scheduleType':
                        _selectedOption == 0 ? 'recurring' : 'specific',
                  },
                );
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
                      text: "Delivery Availability",
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              MyText(text: "Step 4/5", size: 14, color: kSubText),
            ],
          ),
          Gap(32),

          // Instant booking header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                MyText(
                  text: "Instant booking (auto-confirmed)",
                  size: 18,
                  weight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Gap(32),

          // Recurring schedule option
          Bounce(
            onTap: () {
              setState(() {
                _selectedOption = 0;
                _showError = false;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _selectedOption == 0
                    ? kPrimaryColor.withOpacity(0.2)
                    : kWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedOption == 0
                      ? kPrimaryColor
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: MyText(
                text: "Recurring schedule",
                size: 16,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Gap(20),

          // Specific dates only option
          Bounce(
            onTap: () {
              setState(() {
                _selectedOption = 1;
                _showError = false;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _selectedOption == 1
                    ? kPrimaryColor.withOpacity(0.2)
                    : kWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedOption == 1
                      ? kPrimaryColor
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: MyText(
                text: "Specific dates only",
                size: 16,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Gap(24),

          // Error message
          if (_showError)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kredColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: kredColor, size: 24),
                  Gap(12),
                  MyText(
                    text: "Please select an option",
                    size: 16,
                    color: kredColor,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ),

          Gap(100),
        ],
      ),
    );
  }
}