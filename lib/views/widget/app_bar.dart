import 'package:bounce/bounce.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class HeaderAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? lastItem;
  final double? paddingTop;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;

  const HeaderAppBar({
    super.key,
    required this.title,
    this.onTap,
    this.lastItem,
    this.paddingTop,
    this.paddingLeft,
    this.paddingRight,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: paddingTop ?? 50,
        left: paddingLeft ?? 16,
        right: paddingRight ?? 16,
        bottom: paddingBottom ?? 16,
      ),
      child: Row(
        children: [
          Bounce(
            onTap: onTap ?? () => Get.back(),
            child: CommonImageView(
              imagePath: Assets.imagesBackArrowAppbar,
              height: 34,
            ),
          ),
          Expanded(
            child: MyText(
              text: title,
              size: 20,
              weight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          lastItem ?? const Gap(24), // Keeps title centered if no last item
        ],
      ),
    );
  }
}
