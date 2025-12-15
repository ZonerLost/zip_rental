import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_row.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    this.hasseeall = true,
    this.title,
    this.ontap,
    this.img,
  });
  final bool? hasseeall;
  final VoidCallback? ontap;
  final String? title;
  final String? img;
  @override
  Widget build(BuildContext context) {
    return AnimatedRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            MyText(
              text: title ?? 'New Jobs',
              color: kBlack,
              size: 16,
              paddingRight: 10,
              weight: FontWeight.bold,
            ),
            CommonImageView(imagePath: img, height: 18),
          ],
        ),
        const Spacer(),
        if (hasseeall == true)
          Bounce(
            onTap: ontap,
            child: const MyText(
              text: 'See all',
              color: kPrimaryColor,
              size: 14,
              weight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
