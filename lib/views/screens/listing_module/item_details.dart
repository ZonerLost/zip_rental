import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ListingItemDetailsScreen extends StatefulWidget {
  const ListingItemDetailsScreen({super.key});

  @override
  State<ListingItemDetailsScreen> createState() =>
      _ListingItemDetailsScreenState();
}

class _ListingItemDetailsScreenState extends State<ListingItemDetailsScreen> {
  bool isAvailable = true;

  final Map<String, dynamic> item = {
    'title': 'Nike Jordan 6',
    'category': 'Footwear',
    'price': '\$50.00/month',
    'customerName': 'Mike Hesson',
    'condition': '9/10',
    'rentalDuration': '3 months',
    'deliveryDate': 'Oct 20, 2001',
    'onRentSince': 'Oct 23, 2025',
    'address': 'St3 , Wilson road , Brooklyn, USA 10121',
    'co2Saved': '{X}',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    radius: 25,
                    onTap: () {},
                    buttonText: "Delete",
                    fontColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.15),
                    hasgrad: false,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: MyButton(
                    radius: 25,
                    onTap: () {},
                    buttonText: "Edit",
                    backgroundColor: kPrimaryColor,
                    hasgrad: false,
                  ),
                ),
              ],
            ),
            const Gap(12),
          ],
        ),
      ),
      body: AnimatedListView(
        padding: AppSizes.DEFAULT,
        children: [
          const Gap(50),

          /// HEADER
          Row(
            children: [
              Bounce(
                onTap: () => Get.back(),
                child: CommonImageView(
                  imagePath: Assets.imagesBack,
                  height: 45,
                ),
              ),
              const Gap(12),
              MyText(text: "Item Details", size: 20, weight: FontWeight.w600),
            ],
          ),

          const Gap(24),

          /// CO2 SAVED INFO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: kPrimaryColor),
                const Gap(12),
                Expanded(
                  child: MyText(
                    text:
                        'Together, we saved ${item['co2Saved']} kg of CO₂ with this item and made sustainable choices!',
                    size: 14,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          const Gap(20),

          /// PRODUCT CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CommonImageView(
                        imagePath: Assets.imagesShoes1,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: item['title'],
                            size: 20,
                            weight: FontWeight.w600,
                          ),
                          const Gap(4),
                          MyText(
                            text:
                                '${item['category']} | ${item['price'].split('/')[0]}',
                            size: 14,
                            color: kSubText,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.2),

                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: MyText(
                        text: "On Rent",
                        size: 13,
                        color: kPrimaryColor,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const Gap(20),
                Divider(color: kBorderColor),
                const Gap(16),

                _detailRow("Customer Name", item['customerName']),
                _detailRow("Condition", item['condition']),
                _detailRow("Category", item['category']),
                _detailRow("Rental Duration", item['rentalDuration']),
                _detailRow("Delivery Date", item['deliveryDate']),
                _detailRow("On rent since", item['onRentSince']),
                _detailRow("Price", item['price']),

                const Gap(8),
              ],
            ),
          ),

          const Gap(16),

          /// HOME ADDRESS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CommonImageView(imagePath: Assets.imagesMapPin2, height: 40),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: "Home Address",
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                      const Gap(4),
                      MyText(text: item['address'], size: 14, color: kSubText),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          /// PICKUP/DELIVERY
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CommonImageView(imagePath: Assets.imagesTruck, height: 40),

                const Gap(16),
                Expanded(
                  child: Row(
                    children: [
                      MyText(
                        text: "Pickup / Delivery",
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                      const Gap(8),
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: 6,

                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesEditProfile2,
                      height: 16,
                    ),
                    MyText(
                      text: 'Edit',
                      size: 14,
                      color: kPrimaryColor,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(16),

          /// AVAILABILITY
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CommonImageView(
                  imagePath: Assets.imagesNewCalender2,
                  height: 40,
                ),

                const Gap(16),
                Expanded(
                  child: MyText(
                    text: "Availability",
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: isAvailable,

                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                  activeColor: kPrimaryColor,
                ),
              ],
            ),
          ),

          const Gap(100),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(text: title, size: 14, color: kSubText),
          MyText(text: value, size: 14, weight: FontWeight.w600),
        ],
      ),
    );
  }
}
