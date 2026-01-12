import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ListingRentalScreen extends StatefulWidget {
  const ListingRentalScreen({super.key});

  @override
  State<ListingRentalScreen> createState() => _ListingRentalScreenState();
}

class _ListingRentalScreenState extends State<ListingRentalScreen> {
  final Map<String, dynamic> item = {
    'title': 'Nike Jordan 6',
    'category': 'Footwear',
    'price': '\$50.00',
    'customerName': 'Mike Hesson',
    'deliveryDate': 'Oct 20, 2001',
    'address': 'St3 , Wilson road , Brooklyn, USA 10121',
    'timeLeft': 'You have left 23 hrs to accept the offer.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    radius: 25,
                    onTap: () => Get.back(),
                    buttonText: "Decline",
                    fontColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.15),
                    hasgrad: false,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: MyButton(
                    radius: 25,
                    onTap: () {
                      
                      showRequestAcceptedBottomSheet(context);
                  
                    },
                    buttonText: "Accept",
                    backgroundColor: kPrimaryColor,
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
              MyText(text: "My Rental", size: 20, weight: FontWeight.w600),
            ],
          ),

          const Gap(24),

          /// CONTENT
          Container(
            margin: EdgeInsets.all(0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: kPrimaryColor),
                const Gap(8),
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

          const Gap(20),

          /// PRODUCT CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CommonImageView(
                        imagePath: Assets.imagesShoes1,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: item['title'],
                            size: 18,
                            weight: FontWeight.w600,
                          ),
                          const Gap(4),
                          MyText(
                            text: '${item['category']} | ${item['price']}',
                            size: 14,
                            color: kSubText,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: MyText(
                        text: "New Request",
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
                _detailRow("Customer Name", "Mike Hesson"),

                _detailRow("Delivery Date", item['deliveryDate']),

                const Gap(16),
              ],
            ),
          ),

          const Gap(20),

          /// ADDRESS
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                /// CUSTOMER INFO
                Row(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesChatAvatar,
                      height: 40,
                    ),
                    const Gap(12),
                    Expanded(
                      child: MyText(
                        text: item['customerName'],
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                    CommonImageView(
                      imagePath: Assets.imagesCommentsNewIcon,
                      height: 40,
                    ),
                  ],
                ),
          ),
          const Gap(12),

          /// ADDRESS
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CommonImageView(imagePath: Assets.imagesMapPin2, height: 50),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: "Home Address",
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                      const Gap(4),
                      MyText(text: item['address'], size: 13, color: kSubText),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Gap(12),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
