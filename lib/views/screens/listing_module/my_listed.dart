import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/listing_module/item_details.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class MyListedItemsScreen extends StatefulWidget {
  const MyListedItemsScreen({super.key});

  @override
  State<MyListedItemsScreen> createState() => _MyListedItemsScreenState();
}

class _MyListedItemsScreenState extends State<MyListedItemsScreen> {
  // Track pause state for each item
  Map<int, bool> pausedItems = {};

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

  final List<Map<String, dynamic>> CompletedItems = [
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'price': '\$50.00',
      'customerName': 'Mike Hesson',
      'deliveryDate': 'Oct 20, 2001',
      'address': 'St3, Wilson road, Brooklyn',
      'type': 'Delivery',
      'timeLeft': '23 hr ago Completed.',
    },
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'price': '\$50.00',
      'customerName': 'Mike Hesson',
      'deliveryDate': 'Oct 20, 2001',
      'address': 'St3, Wilson road, Brooklyn',
      'type': 'Delivery',
      'timeLeft': '23 hr ago Completed.',
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
                  MyText(
                    text: "My Listings",
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                  Bounce(
                    onTap: () {
                      // Get.to(() => const AddNewItemScreen());
                    },
                    child: CommonImageView(
                      imagePath: Assets.imagesNavAdd,
                      height: 40,
                    ),
                  ),
                ],
              ),
              Gap(24),
              Expanded(child: _buildActiveItemsTab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveItemsTab() {
    return ListView.builder(
      itemCount: activeItems.length,
      itemBuilder: (context, index) {
        final item = activeItems[index];
        final isPaused = pausedItems[index] ?? false;

        return GestureDetector(
          onTap: () {
            // Navigate to edit listing screen
            Get.to(() => const ListingItemDetailsScreen());
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isPaused ? kPrimaryColor: Colors.transparent,
                width: 2,
              ),
              color: isPaused
                  ? kPrimaryColor.withOpacity(
                      0.1,
                    ) // Red with 0.03 opacity if paused
                  : kWhite, // Otherwise white
              borderRadius: BorderRadius.circular(25),
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
                // Item Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CommonImageView(
                          imagePath: Assets.imagesShoes1,
                          height: 60,
                        ),
                        Gap(12),
                        MyText(
                          text: item['title'],
                          size: 18,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
                Gap(16),

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

                // Pause listing toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: 'Pause listing',
                      size: 16,
                      weight: FontWeight.w500,
                      color: kPrimaryColor,
                    ),
                    Switch(
                      value: isPaused,
                      onChanged: (value) {
                        setState(() {
                          pausedItems[index] = value;
                        });
                      },
                      activeColor: kPrimaryColor,
                      inactiveTrackColor: kWhite,
                      inactiveThumbColor: kBlack,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
