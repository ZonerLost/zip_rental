// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:bounce/bounce.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Gap(50),
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
                text: "Privacy Policy",
                size: 18,
                color: kBlack,
                weight: FontWeight.w600,
              ),
            ],
          ),
          Gap(50), // Scrollable Content
          MyText(
            text: "Effective Date: 10/29/2025\nLast Updated: 10/29/2025",
            size: 16,
            color: kSubText2,
            weight: FontWeight.w500,
          ),
          const Gap(20),

          // Intro
          _buildParagraph(
            "At ZIP(“we,” “us,” or “our”), your privacy is our top priority. This Privacy Policy explains how we collect, use, share, and protect your information when you use our AI-driven DIY credit repair app, website, or related services (“Services”).",
          ),
          const Gap(16),
          _buildParagraph(
            "By using the App, you agree to this Privacy Policy. If you do not agree, please discontinue use of the Services.",
          ),
          const Gap(30),

          // Section 1
          _buildSectionTitle("1. Information We Collect"),
          _buildParagraph(
            "We collect information to provide accurate, secure, and customized credit education and AI-based tools.",
          ),
          const Gap(16),

          _buildSubSection("a. Information You Provide"),
          _buildBullet(
            "Account Details: Name, email address, phone number, and login credentials.",
          ),
          _buildBullet(
            "Billing & Subscription Info: Payment method, subscription plan, and renewal preferences.",
          ),
          _buildBullet(
            "Credit Report Data: Credit reports, account balances, or creditor information you voluntarily upload or connect through SmartCredit.com or another third-party provider.",
          ),
          _buildBullet(
            "Communications: Emails or chat messages you send to our support team.",
          ),
          const Gap(16),

          _buildSubSection("b. Information Collected Automatically"),
          _buildBullet(
            "Device Data: IP address, browser type, operating system, and device identifiers.",
          ),
          _buildBullet(
            "Usage Analytics: Features used, time spent, and in-app actions.",
          ),
          _buildBullet(
            "Cookies & Tracking: For login sessions, analytics, and user preferences.",
          ),
          const Gap(30),

          // Section 2
          _buildSectionTitle("2. SmartCredit.com Integration"),
          _buildBullet(
            "To useZIP, users must maintain an active SmartCredit.com monitoring account.",
          ),
          _buildBullet(
            "SmartCredit.com is an independent third-party company not owned or operated by Paramount Credit Services orZIP.",
          ),
          _buildBullet(
            "When you connect your Smart Credit account, you authorize us to securely access your credit report data through their encrypted API for analysis, tracking, and dispute generation.",
          ),
          _buildBullet(
            "Your Smart Credit login information is never stored on our servers. All authentication is handled through Smart Credit’s secure connection.",
          ),
          _buildBullet(
            "Smart Credit’s own Privacy Policy and Terms of Use govern how they collect, store, and use your data. We encourage you to review their policies at www.smartcredit.com/privacy-policy.",
          ),
          _buildBullet(
            "If your Smart Credit subscription is canceled or inactive, certain ZIPfeatures may be paused until monitoring is restored.",
          ),
          const Gap(30),

          // Section 3
          _buildSectionTitle("3. How We Use Your Information"),
          _buildParagraph("We use your information to:"),
          _buildBullet(
            "Generate AI-based insights and educational tools to help you improve credit health.",
          ),
          _buildBullet("Automatically prepare personalized dispute letters."),
          _buildBullet("Manage billing, subscriptions, and customer support."),
          _buildBullet(
            "Send notifications, progress updates, and educational materials.",
          ),
          _buildBullet(
            "Monitor performance and maintain security of our platform.",
          ),
          const Gap(12),
          _buildParagraph(
            "We never sell or rent your personal data to any third party.",
            bold: true,
          ),
          const Gap(30),

          // Section 4
          _buildSectionTitle("4. How We Share Information"),
          _buildParagraph("We only share limited data with:"),
          _buildBullet("SmartCredit.com, when you authorize connection."),
          _buildBullet("Payment processors, to securely process payments."),
          _buildBullet(
            "Cloud service providers, to store and manage data securely.",
          ),
          _buildBullet(
            "Analytics tools, to improve app functionality (non-identifiable data only).",
          ),
          const Gap(16),
          _buildParagraph(
            "All third-party partners are contractually required to safeguard your data and use it only for the purposes we authorize.",
          ),
          const Gap(30),

          // Section 5
          _buildSectionTitle("5. AI Data Processing"),
          _buildBullet(
            "Our AI analyzes your credit data to provide personalized education and recommendations.",
          ),
          _buildBullet(
            "AI results are informational and not guaranteed to be free from errors.",
          ),
          _buildBullet(
            "We do not use your personal data to train external AI systems.",
          ),
          _buildBullet(
            "Your data remains confidential and encrypted at all times.",
          ),
          const Gap(30),

          // Section 6
          _buildSectionTitle("6. Data Security"),
          _buildParagraph(
            "We use bank-level encryption, secure data storage, and limited employee access to protect your information.",
          ),
          _buildParagraph(
            "However, no system is entirely immune to security risks. You are responsible for protecting your password and access to your account.",
          ),
          const Gap(30),

          // Section 7
          _buildSectionTitle("7. Data Retention"),
          _buildParagraph(
            "We retain your information for as long as necessary to:",
          ),
          _buildBullet("Provide and improve our Services,"),
          _buildBullet("Comply with legal and regulatory obligations, and"),
          _buildBullet("Resolve disputes."),
          const Gap(12),
          _buildParagraph(
            "You mayrequest data deletion at any time (see Section 10).",
          ),
          const Gap(30),

          // Section 8
          _buildSectionTitle("8. Children’s Privacy"),
          _buildParagraph(
            "Our Services are intended for adults 18 years and older. We do not knowingly collect information from children under 18.",
          ),
          const Gap(30),

          // Section 9
          _buildSectionTitle("9. Your Rights"),
          _buildParagraph(
            "Depending on your jurisdiction, you may have the right to:",
          ),
          _buildBullet("Access or request a copy of your data."),
          _buildBullet("Correct inaccurate information."),
          _buildBullet("Request deletion of your data."),
          _buildBullet("Withdraw consent for certain uses."),
          const Gap(16),
          _buildParagraph(
            "To exercise your rights, contact us at [Insert Support Email]. We will respond within a reasonable timeframe.",
          ),
          const Gap(30),

          // Section 10
          _buildSectionTitle("10. Account and Data Deletion"),
          _buildParagraph(
            "You may delete your account at any time through the App or by contacting support.",
          ),
          _buildParagraph(
            "Once deleted, your account and personal data will be removed from active systems within 30 days, except where retention is required by law (e.g., billing records).",
          ),
          const Gap(30),

          // Section 11
          _buildSectionTitle("11. Third-Party Links"),
          _buildParagraph(
            "Our App may include links to other websites (e.g., SmartCredit.com or educational partners). We are not responsible for the content or privacy practices of those third parties.",
          ),
          const Gap(30),

          // Section 12
          _buildSectionTitle("12. Changes to This Policy"),
          _buildParagraph(
            "We may update this Privacy Policy periodically. Updates take effect immediately upon posting in the App or on our website. Continued use of the App means you accept any changes.",
          ),
          const Gap(30),

          // Section 13
          _buildSectionTitle("13. Contact Us"),
          _buildParagraph(
            "For questions about this Privacy Policy or how we protect your data, contact us:",
          ),
          const Gap(12),
          _buildParagraph("Paramount Credit Pathway", bold: true),
          Row(
            spacing: 6,
            children: [
              _buildParagraph("Email:"),

              _buildParagraphUnderline("Team@paramountcreditpathway.com"),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              _buildParagraph("Website:"),

              _buildParagraphUnderline("www.paramountcreditpathway.com"),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              _buildParagraph("Phone:"),

              _buildParagraph(" 210-355-9232"),
            ],
          ),
          const Gap(40),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String text) {
    return MyText(
      text: text,
      size: 20,
      paddingBottom: 12,
      color: kBlack,
      weight: FontWeight.w700,
    );
  }

  Widget _buildSubSection(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: MyText(
        text: text,
        size: 16,
        color: kBlack,
        weight: FontWeight.w600,
      ),
    );
  }

  Widget _buildParagraph(String text, {bool bold = false}) {
    return MyText(
      text: text,
      size: 16,
      color: kSubText2,
      weight: bold ? FontWeight.w600 : FontWeight.w400,
    );
  }

  Widget _buildParagraphUnderline(String text, {bool bold = false}) {
    return MyText(
      text: text,
      decoration: TextDecoration.underline,
      size: 16,
      color: kSubText2,
      weight: bold ? FontWeight.w600 : FontWeight.w400,
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(text: "• ", size: 16, color: kSubText2),
          Expanded(
            child: MyText(text: text, size: 16, color: kSubText2),
          ),
        ],
      ),
    );
  }
}
