import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class MyListedItemsScreen extends StatefulWidget {
  const MyListedItemsScreen({super.key});

  @override
  State<MyListedItemsScreen> createState() => _MyListedItemsScreenState();
}

class _MyListedItemsScreenState extends State<MyListedItemsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Requests', 'Active Items', 'Completed'];

  final List<Map<String, dynamic>> requestItems = [
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'price': '\$50.00',
      'customerName': 'Mike Hesson',
      'deliveryDate': 'Oct 20, 2001',
      'address': 'St3, Wilson road, Brooklyn',
      'type': 'Delivery',
      'timeLeft': 'You have left 23 hrs to accept the offer.',
    },
  ];

  final List<Map<String, dynamic>> activeItems = [
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'condition': '9/10',
      'rentalDuration': '3 months',
      'onRentSince': 'Oct 23, 2025',
      'price': '\$50.00/month',
      'address': 'Lorem ipsum dolors',
      'co2Saved':
          'Together, we saved {X} kg of CO₂ with this item and made sustainable choices!',
    },
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'condition': '9/10',
      'rentalDuration': '3 months',
      'onRentSince': 'Oct 23, 2025',
      'price': '\$50.00/month',
      'address': 'Lorem ipsum dolors',
      'co2Saved':
          'Together, we saved {X} kg of CO₂ with this item and made sustainable choices!',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        text: "My Listed Items",
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  Bounce(
                    onTap: () {
                      // Add new item
                    },
                    child: CommonImageView(
                      imagePath: Assets.imagesNavAdd,
                      height: 40,
                    ),
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

              // Content
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildRequestsTab()
                    : _selectedTabIndex == 1
                    ? _buildActiveItemsTab()
                    : _buildCompletedTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      itemCount: requestItems.length,
      itemBuilder: (context, index) {
        final item = requestItems[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
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
              // Time Warning
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesInfoCircle,
                      height: 20,
                    ),
                    Gap(8),
                    Expanded(
                      child: MyText(
                        text: item['timeLeft'],
                        size: 13,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16),

              // Item Info
              Row(
                children: [
                  CommonImageView(imagePath: Assets.imagesShoes1, height: 60),
                  Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: item['title'],
                          size: 18,
                          weight: FontWeight.w600,
                        ),
                        Gap(4),
                        MyText(
                          text: '${item['category']} | ${item['price']}',
                          size: 14,
                          color: kSubText,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MyText(
                      text: item['type'],
                      size: 13,
                      color: kPrimaryColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Gap(20),

              // Details
              _buildDetailRow('Customer Name', item['customerName']),
              Gap(12),
              _buildDetailRow('Delivery Date', item['deliveryDate']),
              Gap(12),
              _buildDetailRow('Customer address', item['address']),
              Gap(20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: () {},
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      radius: 30,
                      height: 56,
                      buttonText: "Decline",
                      fontColor: kredColor,
                      backgroundColor: kredColor.withOpacity(0.2),
                      hasgrad: false,
                    ),
                  ),
                  Gap(12),
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        showRequestAcceptedBottomSheet(context);
                      },
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      radius: 30,
                      height: 56,
                      buttonText: "Accept",
                      fontColor: kWhite,
                      backgroundColor: kPrimaryColor,
                      hasgrad: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveItemsTab() {
    return ListView.builder(
      itemCount: activeItems.length,
      itemBuilder: (context, index) {
        final item = activeItems[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
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
              // CO2 Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesInfoCircle,
                      height: 20,
                    ),
                    Gap(8),
                    Expanded(
                      child: MyText(
                        text: item['co2Saved'],
                        size: 12,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16),

              // Item Info
              Row(
                children: [
                  CommonImageView(imagePath: Assets.imagesShoes1, height: 60),

                  Gap(12),
                  Expanded(
                    child: MyText(
                      text: item['title'],
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kgreenColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MyText(
                      text: 'Active',
                      size: 13,
                      weight: FontWeight.w500,
                      color: kgreenColor,
                    ),
                  ),
                ],
              ),
              Gap(20),

              // Details
              _buildDetailRow('Category', item['category']),
              Gap(12),
              _buildDetailRow('Condition', item['condition']),
              Gap(12),
              _buildDetailRow('Rental Duration', item['rentalDuration']),
              Gap(12),
              _buildDetailRow('On rent since', item['onRentSince']),
              Gap(12),
              _buildDetailRow('Price', item['price']),
              Gap(12),
              _buildDetailRow('Address', item['address']),
              Gap(20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: () {},
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      radius: 30,
                      height: 56,
                      buttonText: "Delete",
                      fontColor: kredColor,
                      backgroundColor: kredColor.withOpacity(0.2),
                      hasgrad: false,
                    ),
                  ),
                  Gap(12),
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        showReviewRatingBottomSheet(context);
                      },
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      radius: 30,
                      height: 56,
                      buttonText: "Edit",
                      fontColor: kWhite,
                      backgroundColor: kPrimaryColor,
                      hasgrad: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: kPrimaryColor),
          Gap(16),
          MyText(text: 'No Completed Items', size: 18, weight: FontWeight.w600),
          Gap(8),
          MyText(
            text: 'Your completed rentals will appear here',
            size: 14,
            color: kSubText,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(text: label, size: 14, color: kSubText),
        MyText(text: value, size: 14, weight: FontWeight.w600),
      ],
    );
  }
}
