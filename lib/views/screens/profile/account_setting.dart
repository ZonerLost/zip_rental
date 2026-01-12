// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/profile/change_password.dart';
import 'package:zip_peer/views/screens/profile/help_center.dart';
import 'package:zip_peer/views/screens/profile/language.dart';
import 'package:zip_peer/views/screens/profile/privacy_policy.dart';
import 'package:zip_peer/views/screens/profile/terms_condition.dart';
import 'package:zip_peer/views/screens/subscriptions/address.dart';
import 'package:zip_peer/views/screens/subscriptions/payment.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool notificationsEnabled = true;
  bool faceEnabled = true;

  List<Map<String, dynamic>> get settingsItems => [
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
      "value": notificationsEnabled,
      "onToggle": (bool value) {
        setState(() => notificationsEnabled = value);
      },
    },
  ];

  List<Map<String, dynamic>> get HelpsettingsItems => [
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

  @override
  Widget build(BuildContext context) {
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
                Text: item["Text"] ?? "",
                iconPath: item["icon"],
                title: item["title"],
                hasArrow: item["hasArrow"] ?? false,
                hasToggle: item["hasToggle"] ?? false,
                hasText: (item["Text"] ?? "").toString().isNotEmpty,
                value: item["value"],
                onToggle: item["onToggle"] as Function(bool)?,
                onTap: item["onTap"],
              );
            }).toList(),

            const Gap(20),
            // User Preferences Section
            MyText(
              text: "About",
              size: 14,
              paddingBottom: 20,
              color: kSubText,
              weight: FontWeight.w600,
            ),
            ...HelpsettingsItems.map((item) {
              return _buildSettingItem(
                Text: item["Text"] ?? "",
                iconPath: item["icon"],
                title: item["title"],
                hasArrow: item["hasArrow"] ?? false,
                hasToggle: item["hasToggle"] ?? false,
                hasText: (item["Text"] ?? "").toString().isNotEmpty,
                value: item["value"],
                onToggle: item["onToggle"] as Function(bool)?,
                onTap: item["onTap"],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String iconPath,
    required String title,
    required String Text,
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
                        text: Text,
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

  Widget _buildPreferenceItem({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Bounce(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MyText(
                    text: title,
                    size: 16,
                    weight: FontWeight.w500,
                    color: kBlack,
                  ),
                ),
                if (value.isNotEmpty)
                  MyText(
                    text: value,
                    size: 14,
                    weight: FontWeight.w500,
                    color: kSubText2,
                  ),
                const Gap(8),
                const Icon(Icons.chevron_right, color: kBlack, size: 24),
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
