import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/screens/profile/account_setting.dart';
import 'package:zip_peer/views/screens/profile/eco_imapct.dart';
import 'package:zip_peer/views/screens/profile/rental.dart';
import 'package:zip_peer/views/screens/profile/user_profile_widgets.dart';
import 'package:zip_peer/views/screens/subscriptions/payment.dart';
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
          MyText(
            text: 'Dashboard',
            size: 24,
            paddingBottom: 20,
            color: kBlack,
            weight: FontWeight.w600,
          ),

          // Profile Card
          const ProfileCardWidget(),

          const Gap(20),

          // Earnings Card
          const EarningsCardWidget(),

          const Gap(20),

          // Eco Impact Card
          const EcoImpactCardWidget(),

          const Gap(20),

          // Most Rented Items
          const MostRentedItemsWidget(),

          const Gap(30),

          // Settings Label
          Align(
            alignment: Alignment.centerLeft,
            child: MyText(
              text: 'SETTINGS',
              size: 12,
              letterSpacing: 1,
              color: kSubText2,
              weight: FontWeight.w500,
            ),
          ),

          const Gap(12),

          // Settings Items
          SettingItemWidget(
            icon: Assets.imagesSetting,
            title: 'Account Settings',
            onTap: () {
              Get.to(() => const AccountSettingsScreen());
            },
          ),

          SettingItemWidget(
            icon: Assets.imagesMapPin,
            title: 'Payout Information',
            onTap: () {
              Get.to(() => PaymentMethodsScreen());
            },
          ),

          // SettingItemWidget(
          //   icon: Assets.imagesListedItem,
          //   title: 'My Rentals',
          //   onTap: () {
          //     Get.to(() => RentalScreen());
          //   },
          // ),

          SettingItemWidget(
            icon: Assets.imagesLogout2,
            title: 'Logout',
            onTap: () {
              LogoutBottomSheet(context);
            },
          ),

          const Gap(100),
        ],
      ),
    );
  }
}
