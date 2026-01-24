import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/instant_booking.dart';
import 'package:zip_peer/views/screens/add_item_module/bosst.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class DeliveryAvailabilityScreen extends StatefulWidget {
  const DeliveryAvailabilityScreen({super.key});

  @override
  State<DeliveryAvailabilityScreen> createState() =>
      _DeliveryAvailabilityScreenState();
}

class _DeliveryAvailabilityScreenState
    extends State<DeliveryAvailabilityScreen> {
  int? _selectedBookingType; // null = not selected, 0 = manual, 1 = instant
  bool _showError = false;
  String rentalType = 'delivery';

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['rentalType'] != null) {
      rentalType = Get.arguments['rentalType'];
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
                if (_selectedBookingType == null) {
                  setState(() {
                    _showError = true;
                  });
                  return;
                }

                // Navigate based on booking type
                if (_selectedBookingType == 1) {
                  // Instant booking selected - show instant booking options
                  Get.to(
                    () => InstantBookingOptionsScreen(),
                    arguments: {
                      'bookingType': 'instant',
                      'rentalType': rentalType,
                    },
                  );
                } else {
                  // Manual approval selected - skip to boost
                  Get.to(
                    () => BoostScreen(),
                    arguments: {
                      'bookingType': 'manual',
                      'rentalType': rentalType,
                    },
                  );
                }
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
              MyText(text: "Step 3/5", size: 14, color: kSubText),
            ],
          ),
          Gap(40),

          // Request to book option
          Bounce(
            onTap: () {
              setState(() {
                _selectedBookingType = 0;
                _showError = false;
              });
            },
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedBookingType == 0
                    ? kPrimaryColor.withOpacity(0.2)
                    : kWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedBookingType == 0
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                    text: "Request to book (manual approval)",
                    size: 18,
                    weight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  Gap(16),
                  MyText(
                    text:
                        "Renters can request any date/time.\nYou'll have X hours to accept, decline, or\npropose a new time.",
                    size: 14,
                    color: kSubText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Gap(24),

          // Instant booking option
          Bounce(
            onTap: () {
              setState(() {
                _selectedBookingType = 1;
                _showError = false;
              });
            },
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedBookingType == 1
                    ? kPrimaryColor.withOpacity(0.2)
                    : kWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedBookingType == 1
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                    text: "Instant booking (auto-confirmed)",
                    size: 18,
                    weight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  Gap(16),
                  Column(
                    children: [
                      MyText(
                        text:
                            "Renters can instantly book only the green\ntime slots you set.",
                        size: 14,
                        color: kSubText,
                        textAlign: TextAlign.center,
                      ),
                      Gap(8),
                      MyText(
                        text: "Everything else requires a request",
                        size: 14,
                        color: kBlack,
                        weight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
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
                    text: "Please select a booking type",
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