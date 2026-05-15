import 'package:bounce/bounce.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/profile/help_support_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HelpSupportController>(
      init: HelpSupportController(),
      builder: (controller) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      text: 'Help & Support',
                      size: 18,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(30),
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.faqs.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (_, i) {
                      final item = controller.faqs[i];
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
                                      text: item['q']!,
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
                                    text: item['a']!,
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
      },
    );
  }
}
