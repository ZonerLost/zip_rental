// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/profile/account_settings_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/profile/change_password.dart';
import 'package:zip_peer/views/screens/profile/help_center.dart';
import 'package:zip_peer/views/screens/profile/language.dart';
import 'package:zip_peer/views/screens/profile/privacy_policy.dart';
import 'package:zip_peer/views/screens/profile/terms_condition.dart';
import 'package:zip_peer/views/screens/subscriptions/address.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountSettingsController>(
      init: AccountSettingsController(),
      builder: (controller) {
        final List<Map<String, dynamic>> settingsItems = [
          {
            "icon": Assets.imagesPasswordKey,
            "title": "Change Password",
            "hasArrow": true,
            "Text": "",
            "onTap": () {
              Get.to(() => ChangePasswordScreen());
            },
          },
          {
            "icon": Assets.imagesMapPin,
            "title": "My Address",
            "hasArrow": true,
            "Text": "",
            "onTap": () {
              Get.to(() => MyAddressesScreen());
            },
          },
          {
            "icon": Assets.imagesGlobal,
            "title": "Language",
            "hasArrow": true,
            "Text": "",
            "onTap": () {
              Get.to(() => LanguageScreen());
            },
          },
          {
            "icon": Assets.imagesNotificationBlack,
            "title": "Enable Notifications",
            "hasToggle": true,
            "Text": "",
            "value": controller.notificationsEnabled,
            "onToggle": controller.onNotificationToggle,
          },
        ];

        final List<Map<String, dynamic>> helpSettingsItems = [
          {
            "icon": Assets.imagesHelp,
            "title": "Help & Support",
            "hasArrow": true,
            "Text": "",
            "onTap": () {
              Get.to(() => HelpSupportScreen());
            },
          },
          {
            "icon": Assets.imagesInfo,
            "title": "Privacy Policy",
            "hasArrow": true,
            "Text": "",
            "onTap": () {
              Get.to(() => PrivacyPolicyScreen());
            },
          },
          {
            "icon": Assets.imagesTerms,
            "title": "Terms & Conditions",
            "hasArrow": true,
            "Text": "",
            "onTap": () {
              Get.to(() => TermsAndConditionsScreen());
            },
          },
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              children: [
                const Gap(50),
                Row(
                  children: [
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 50,
                      ),
                    ),
                    const Gap(10),
                    MyText(
                      text: "Account Settings",
                      size: 16,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(30),
                ...settingsItems.map((item) {
                  return _buildSettingItem(
                    trailingText: (item["Text"] ?? "").toString(),
                    iconPath: item["icon"].toString(),
                    title: item["title"].toString(),
                    hasArrow: item["hasArrow"] as bool? ?? false,
                    hasToggle: item["hasToggle"] as bool? ?? false,
                    hasText: (item["Text"] ?? "").toString().isNotEmpty,
                    value: item["value"] as bool?,
                    onToggle: item["onToggle"] as Function(bool)?,
                    onTap: item["onTap"] as VoidCallback?,
                  );
                }),
                const Gap(20),
                MyText(
                  text: "About",
                  size: 14,
                  paddingBottom: 20,
                  color: kSubText,
                  weight: FontWeight.w600,
                ),
                ...helpSettingsItems.map((item) {
                  return _buildSettingItem(
                    trailingText: (item["Text"] ?? "").toString(),
                    iconPath: item["icon"].toString(),
                    title: item["title"].toString(),
                    hasArrow: item["hasArrow"] as bool? ?? false,
                    hasToggle: item["hasToggle"] as bool? ?? false,
                    hasText: (item["Text"] ?? "").toString().isNotEmpty,
                    value: item["value"] as bool?,
                    onToggle: item["onToggle"] as Function(bool)?,
                    onTap: item["onTap"] as VoidCallback?,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required String iconPath,
    required String title,
    required String trailingText,
    bool hasArrow = false,
    bool hasToggle = false,
    bool hasText = false,
    bool? value,
    Color? color,
    VoidCallback? onTap,
    Function(bool)? onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Bounce(
        onTap: hasToggle ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CommonImageView(imagePath: iconPath, height: 44),
              const Gap(16),

              Expanded(
                child: MyText(
                  text: title,
                  size: 16,
                  weight: FontWeight.w500,
                  color: color ?? kBlack,
                ),
              ),

              if (hasToggle)
                Switch(
                  value: value ?? false,
                  onChanged: onToggle,
                  activeColor: kPrimaryColor,
                  activeTrackColor: kPrimaryColor,
                  thumbColor: WidgetStateProperty.all(kWhite),
                )
              else if (hasArrow)
                Row(
                  children: [
                    if (hasText)
                      MyText(
                        text: trailingText,
                        size: 14,
                        weight: FontWeight.w500,
                        color: kSubText2,
                      ),
                    const Icon(Icons.chevron_right, color: kBlack, size: 24),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
