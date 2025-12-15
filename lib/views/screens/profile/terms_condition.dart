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

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
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
                text: "Terms & Conditions",
                size: 18,
                color: kBlack,
                weight: FontWeight.w600,
              ),
            ],
          ),
          Gap(50),
          MyText(
            text: "Effective Date: 10/29/2025\nLast Updated: 10/29/2025",
            size: 16,
            color: kSubText2,
            weight: FontWeight.w500,
          ),
          const Gap(20),

          // Intro
          _buildParagraph(
            "Welcome toZIP, an AI-driven, do-it-yourself (DIY) credit repair and education platform (“the App”). By using the App, website, or any related services (“Services”), you agree to these Terms and Conditions (“Terms”). Please read them carefully.",
          ),
          const Gap(30),

          // Section 1
          _buildSectionTitle("1. Acceptance of Terms"),
          _buildParagraph(
            "By accessing or using the App, you confirm that you are at least 18 years old and agree to be bound by these Terms and our Privacy Policy. If you do not agree, you may not access or use the Services.",
          ),
          const Gap(30),

          // Section 2
          _buildSectionTitle("2. Nature of Services"),
          _buildParagraph(
            "ZIPprovides automated credit analysis, educational resources, and guided tools to help users understand and manage their credit.",
          ),
          const Gap(16),
          _buildBullet(
            "The App uses AI technology to assist with credit report analysis, letter generation, and educational suggestions.",
          ),
          _buildBullet(
            "ZIPis not a law firm, not a credit bureau, and do not provide legal, tax, or financial advice.",
          ),
          _buildBullet(
            "This is a DIY platform—you are solely responsible for reviewing, submitting, or mailing any correspondence to creditors, collectors, or bureaus.",
          ),
          const Gap(30),

          // Section 3
          _buildSectionTitle("3. No Guarantee of Results"),
          _buildParagraph("Credit repair outcomes vary by individual."),
          const Gap(16),
          _buildBullet(
            "We do not guarantee any specific credit score increase or removal of negative information.",
          ),
          _buildBullet(
            "Results depend on the accuracy of your credit data, your actions, and creditor/bureau responses.",
          ),
          _buildBullet(
            "AI recommendations are informational only and should not replace professional financial or legal advice.",
          ),
          const Gap(30),

          // Section 4
          _buildSectionTitle("4. User Responsibilities"),
          _buildParagraph("You agree to:"),
          const Gap(16),
          _buildBullet("Use the App for lawful purposes only."),
          _buildBullet("Provide accurate, current, and complete information."),
          _buildBullet(
            "Refrain from misusing or attempting to manipulate credit reporting systems.",
          ),
          _buildBullet(
            "Maintain the confidentiality of your login credentials.",
          ),
          const Gap(16),
          _buildParagraph(
            "You are fully responsible for all activities that occur under your account.",
          ),
          const Gap(20),
          _buildSubSection("Smart Credit Monitoring Requirement"),
          _buildParagraph(
            "To useZIP, you must maintain an active Smart Credit monitoring account through the link we provided throughout your subscription period.",
          ),
          const Gap(16),
          _buildBullet(
            "Smart Credit is an independent third-party company and is not affiliated withZIP.",
          ),
          _buildBullet(
            "Your Smart Credit subscription is separate from your ZIPsubscription and billed directly through SmartCredit.com.",
          ),
          _buildBullet(
            "The monitoring connection allows our AI system to securely access your credit data for analysis, updates, and dispute preparation.",
          ),
          _buildBullet(
            "If your Smart Credit subscription lapses, your ZIPfeatures may be paused until your monitoring is reactivated.",
          ),
          _buildBullet(
            "We are not responsible for any billing issues, outages, or disputes related to SmartCredit.com.",
          ),
          const Gap(30),

          // Section 5
          _buildSectionTitle("5. Subscription and Payments"),
          _buildBullet(
            "Some features require a paid subscription (e.g., Smart Credit, Pathway Core, Advantage, or Pro).",
          ),
          _buildBullet(
            "Subscriptions auto-renew unless canceled prior to the renewal date.",
          ),
          _buildBullet(
            "All payments are processed through secure third-party gateways.",
          ),
          _buildBullet(
            "No refunds are provided after digital access has been granted, except as required by law.",
          ),
          const Gap(30),

          // Section 6
          _buildSectionTitle("6. AI-Generated Content"),
          _buildParagraph(
            "AI-generated insights, dispute letters, or recommendations are based on data you provide and are for educational purposes. ZIPdoes not assume responsibility for any errors, omissions, or inaccuracies resulting from AI suggestions.",
          ),
          const Gap(30),

          // Section 7
          _buildSectionTitle("7. Data Privacy"),
          _buildParagraph(
            "Your privacy matters to us. Personal and credit data are handled according to our Privacy Policy.",
          ),
          const Gap(16),
          _buildParagraph(
            "We may use encrypted third-party integrations to securely analyze your credit reports, but your data is never sold or shared for marketing without consent.",
          ),
          const Gap(30),

          // Section 8
          _buildSectionTitle("8. Limitation of Liability"),
          _buildParagraph(
            "To the maximum extent permitted by law, ZIPand its affiliates shall not be liable for:",
          ),
          const Gap(16),
          _buildBullet(
            "Any direct, indirect, incidental, or consequential damages;",
          ),
          _buildBullet(
            "Any loss of data, credit score points, or expected outcomes;",
          ),
          _buildBullet(
            "Any misuse of the Services or user-generated correspondence.",
          ),
          const Gap(30),

          // Section 9
          _buildSectionTitle("9. No Legal Relationship"),
          _buildParagraph(
            "Use of this App does not create an attorney-client or fiduciary relationship. ZIPand its team are credit educators, not legal representatives.",
          ),
          const Gap(30),

          // Section 10
          _buildSectionTitle("10. Termination"),
          _buildParagraph(
            "We reserve the right to suspend or terminate access at any time for misuse, fraud, or violation of these Terms. Upon termination, you must discontinue use of the App and all associated materials.",
          ),
          const Gap(30),

          // Section 11
          _buildSectionTitle("11. Intellectual Property"),
          _buildParagraph(
            "All content, branding, software, and AI processes within the App are the property of Paramount Credit Services. You may not reproduce, modify, or resell any part of the platform.",
          ),
          const Gap(30),

          // Section 12
          _buildSectionTitle("12. Governing Law"),
          _buildParagraph(
            "These Terms are governed by and construed in accordance with the laws of the State of [Your State], without regard to conflict of law principles.",
          ),
          const Gap(30),

          // Section 13
          _buildSectionTitle("13. Updates to Terms"),
          _buildParagraph(
            "We may modify these Terms from time to time. Continued use of the App after changes means you accept the updated version.",
          ),
          const Gap(30),

          // Section 14
          _buildSectionTitle("14. Contact Information"),
          _buildParagraph(
            "For questions about these Terms or the App, please contact:",
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
              _buildParagraph("210-355-9232"),
            ],
          ),
          const Gap(40),
        ],
      ),
    );
  }

  // Helper Widgets (Same as PrivacyPolicyScreen)
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
