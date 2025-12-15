// ignore_for_file: prefer_const_constructors
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:bounce/bounce.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "q": "What is ZIP?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q": "What plan do I need to get help from a live advisor?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q": "How long does it take to see my first updates?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q": "Should I settle my collections before disputing them?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q":
            "Can I switch from DIY to full service with Paramount Credit Services?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q": "What’s included in each Pathway Plan (Core, Advantage, and Pro)?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q": "How long do negative items stay on my report?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q": "How do I create or update my Smart Credit Membership?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
      {
        "q":
            "How can I send my dispute letters online without printing — and which method works best for results?",
        "a":
            "ZIPis an AI-powered, DIY credit improvement platform created by the experts at Paramount Credit Services.\n\nWe combine smart technology with real human guidance to help you take control of your credit and reach your goals with confidence.",
      },
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(50),

            // Header
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
                  text: "Help & Support",
                  size: 18,
                  color: kBlack,
                  weight: FontWeight.w600,
                ),
              ],
            ),
            const Gap(30),

            // FAQ List
            Expanded(
              child: ListView.separated(
                itemCount: faqs.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (_, i) {
                  final item = faqs[i];
                  return ExpandableNotifier(
                    child: Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ExpandablePanel(
                        theme: const ExpandableThemeData(
                          tapHeaderToExpand: true,
                          hasIcon: false,
                          animationDuration: Duration(milliseconds: 300),
                        ),
                        header: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: MyText(
                                  text: item["q"]!,
                                  size: 16,
                                  color: kBlack,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const Gap(8),
                              ExpandableIcon(
                                theme: const ExpandableThemeData(
                                  expandIcon: Icons.add,
                                  collapseIcon: Icons.remove,
                                  iconColor: kBlack,
                                  iconSize: 28,
                                  iconPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                        collapsed: const SizedBox.shrink(),
                        expanded: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Divider line
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Divider(
                                color: kBlack.withOpacity(0.1),
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                16,
                                20,
                                24,
                              ),
                              child: MyText(
                                text: item["a"]!,
                                size: 16,
                                color: kSubText2,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }
}
