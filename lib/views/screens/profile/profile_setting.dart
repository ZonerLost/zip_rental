import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/screens/profile/account_setting.dart';
import 'package:zip_peer/views/screens/profile/eco_imapct.dart';
import 'package:zip_peer/views/screens/profile/edit_profile.dart';
import 'package:zip_peer/views/screens/profile/help_center.dart';
import 'package:zip_peer/views/screens/profile/my_listed.dart';
import 'package:zip_peer/views/screens/profile/privacy_policy.dart';
import 'package:zip_peer/views/screens/profile/rental.dart';
import 'package:zip_peer/views/screens/profile/terms_condition.dart';
import 'package:zip_peer/views/screens/subscriptions/payment.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
        padding: const EdgeInsets.all(20),

        children: [
          // Header
          const Gap(50),

          // ------- NEW PROFILE CARD UI ----------
          Container(
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
                // Profile Image + Edit Button
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
                    CommonImageView(
                      imagePath: Assets.imagesVerfiyTick,
                      height: 18,
                    ),
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

                // ===== STATS ROW =====
                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [_buildStatItem("22", "Rentals")]),
                    Container(height: 40, width: 1, color: kDividerColor),

                    _buildStatItem("66", "Items Listed"),

                    Container(height: 40, width: 1, color: kDividerColor),

                    _buildStatItem("23", "Orders"),
                  ],
                ),

                const Gap(20),

                // ===== ECO IMPACT BOX =====
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesInfoCircle,
                        height: 20,
                      ),
                      Expanded(
                        child: MyText(
                          text: 'You have saved overall 27 kg CO2 this month',
                          size: 14,
                          color: kPrimaryColor,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),
          Container(
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
                MyText(
                  text: "This Month",
                  size: 12,
                  color: kSubText2,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),

          const Gap(20),

          // Settings Label
          Align(
            alignment: Alignment.centerLeft,
            child: MyText(
              text: 'SETTINGS',
              size: 14,
              letterSpacing: 1,
              color: kSubText2,
              weight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 12),

          // Settings Items
          _buildSettingItem(
            icon: Assets.imagesSetting,
            title: 'Account Settings',
            onTap: () {
              Get.to(() => const AccountSettingsScreen());
            },
          ),
          _buildSettingItem(
            icon: Assets.imagesListedItem,
            title: 'My Listed Items',

            onTap: () {
              Get.to(() => MyListedItemsScreen());
            },
          ),
          _buildSettingItem(
            icon: Assets.imagesEcoImpact,
            title: 'Eco Impact',

            onTap: () {
              Get.to(() => EcoImpactScreen());
            },
          ),
          _buildSettingItem(
            icon: Assets.imagesListedItem,
            title: 'My Rentals',

            onTap: () {
              Get.to(() => RentalScreen());
            },
          ),
          _buildSettingItem(
            icon: Assets.imagesPayout,
            title: 'Payout Information',

            onTap: () {
              Get.to(() => PaymentMethodsScreen());
            },
          ),

          _buildSettingItem(
            icon: Assets.imagesLogout2,
            title: 'Logout',

            onTap: () {
              LogoutBottomSheet(context);
            },
          ),
          Gap(100),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
            spacing: 6,
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

  Widget _buildStatItem(String value, String title) {
    return Column(
      children: [
        MyText(text: value, size: 18, color: kBlack, weight: FontWeight.w600),
        const Gap(4),
        MyText(
          text: title,
          size: 13,
          color: kSubText2,
          weight: FontWeight.w400,
        ),
      ],
    );
  }
}
