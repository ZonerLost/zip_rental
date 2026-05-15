import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/profile/language_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      init: LanguageController(),
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
                      text: 'Language',
                      size: 18,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(40),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: controller.languages.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (_, i) {
                      final lang = controller.languages[i];
                      final isSelected = controller.selected == lang['code'];
                      return Bounce(
                        onTap: () => controller.select(lang['code'].toString()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              MyText(
                                text: lang['flag'].toString(),
                                size: 32,
                                color: kBlack,
                                weight: FontWeight.w500,
                              ),
                              const Gap(16),
                              MyText(
                                text: lang['name'].toString(),
                                size: 16,
                                color: kBlack,
                                weight: FontWeight.w500,
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: kgreenColor,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Gap(30),
                MyButton(
                  height: 60,
                  buttonText: 'Confirm',
                  onTap: () => Get.back(),
                  backgroundColor: kPrimaryColor,
                  fontColor: kWhite,
                  radius: 30,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
