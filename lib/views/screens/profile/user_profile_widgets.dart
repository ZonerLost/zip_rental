import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/profile/edit_profile.dart';
import 'package:zip_peer/views/screens/profile/rental.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ProfileCardWidget extends StatelessWidget {
  const ProfileCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Bounce(
                onTap: () => Get.to(() => EditProfileScreen()),
                child: CommonImageView(
                  imagePath: Assets.imagesEditProfile,
                  height: 40,
                ),
              ),
            ],
          ),

          const Gap(6),

          // Profile Image
          CommonImageView(imagePath: Assets.imagesChatAvatar, height: 70),

          const Gap(14),

          // Name + Blue Tick
          Row(
            spacing: 6,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: 'Christopher Henry',
                size: 18,
                color: kBlack,
                weight: FontWeight.w600,
              ),
              CommonImageView(imagePath: Assets.imagesBadgeNew, height: 18),
            ],
          ),

          const Gap(6),

          // Email
          MyText(
            text: 'christopherhenry344@gmail.com',
            size: 14,
            color: kSubText2,
            weight: FontWeight.w400,
          ),

          const Gap(20),

          // ===== STATS GRID (2x2) =====
          Row(
            spacing: 12,
            children: [
              Expanded(child: _buildLargeStatCard("22 items", "I rented out")),
              Expanded(
                child: _buildLargeStatCard("22 items", "Rented from Others"),
              ),
            ],
          ),

          const Gap(12),

          Row(
            spacing: 12,
            children: [
              Expanded(child: _buildLargeStatCard("22", "Items Listed")),
              Expanded(child: _buildLargeStatCard("4.9", "Ratings")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(text: value, size: 18, color: kBlack, weight: FontWeight.w600),
          const Gap(4),
          MyText(
            text: label,
            size: 13,
            color: kSubText,
            weight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class EarningsCardWidget extends StatelessWidget {
  const EarningsCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: "\$500.99",
                size: 26,
                color: kBlack,
                weight: FontWeight.w600,
              ),
              const Gap(6),
              MyText(
                text: "Earning from rented items",
                size: 14,
                color: kSubText2,
                weight: FontWeight.w400,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              spacing: 4,
              children: [
                MyText(
                  text: "This Month",
                  size: 12,
                  color: kPrimaryColor,
                  weight: FontWeight.w600,
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: kPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EcoImpactCardWidget extends StatelessWidget {
  const EcoImpactCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: "27 Kg",
            size: 26,
            color: kBlack,
            weight: FontWeight.w600,
          ),
          const Gap(6),
          MyText(
            text: "CO₂ saved by renting out items instead of buying",
            size: 14,
            color: kSubText2,
            weight: FontWeight.w400,
          ),
          const Gap(16),
          Row(
            spacing: 6,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bounce(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left, size: 20),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Center(
                    child: MyText(
                      text: "That's equivalent to 500 km driven by car",
                      size: 14,
                      color: kPrimaryColor,
                      weight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Bounce(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),

                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MostRentedItemsWidget extends StatelessWidget {
  const MostRentedItemsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with your actual data
    final rentedItems = [
      {
        'name': 'Nike Jordan 6',
        'category': 'Footwear',
        'price': '\$50.00',
        'customer': 'Mike Hesson',
        'status': 'On Rent',
      },
      {
        'name': 'Canon EOS R5',
        'category': 'Camera',
        'price': '\$120.00',
        'customer': 'Sarah Johnson',
        'status': 'On Rent',
      },
      {
        'name': 'MacBook Pro',
        'category': 'Electronics',
        'price': '\$200.00',
        'customer': 'John Smith',
        'status': 'On Rent',
      },
      {
        'name': 'Camping Tent',
        'category': 'Outdoor',
        'price': '\$35.00',
        'customer': 'Emma Wilson',
        'status': 'On Rent',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: 'Most Rented Items',
          size: 18,
          color: kBlack,
          weight: FontWeight.w600,
        ),
        const Gap(16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: rentedItems.length,
            itemBuilder: (context, index) {
              final item = rentedItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index != rentedItems.length - 1 ? 12 : 0,
                ),
                child: _buildRentedItemCard(
                  name: item['name']!,
                  category: item['category']!,
                  price: item['price']!,
                  customer: item['customer']!,
                  status: item['status']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRentedItemCard({
    required String name,
    required String category,
    required String price,
    required String customer,
    required String status,
  }) {
    return Bounce(
      onTap: () {
        Get.to(() => const RentalScreen());
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CommonImageView(
                  imagePath:
                      Assets.imagesChatAvatar, // Replace with actual image
                  height: 50,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: name,
                        size: 14,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                      const Gap(4),
                      MyText(
                        text: '$category | $price',
                        size: 12,
                        color: kSubText2,
                        weight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MyText(
                    text: status,
                    size: 12,
                    color: kPrimaryColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Divider(height: 1, color: kDividerColor),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: 'Customer Name',
                  size: 13,
                  color: kSubText2,
                  weight: FontWeight.w400,
                ),
                MyText(
                  text: customer,
                  size: 14,
                  color: kBlack,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItemWidget extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const SettingItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Row(
            spacing: 12,
            children: [
              CommonImageView(imagePath: icon, height: 40),
              MyText(
                text: title,
                size: 16,
                color: kBlack,
                weight: FontWeight.w500,
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: kBlack, size: 24),
        ),
      ),
    );
  }
}
