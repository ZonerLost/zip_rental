import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_row.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.height = 56,
    this.width,
    this.backgroundColor,
    this.fontColor,
    this.fontSize,
    this.customChild,
    this.outlineColor = kBorderColor2,
    this.radius = 12,
    this.svgIcon,
    this.haveSvg = false,
    this.choiceIcon,
    this.choiceIconRight,
    this.isleft = false,
    this.isRight = false,
    this.mhoriz = 0,
    this.hasicon = false,
    this.hasshadow = false,
    this.mBottom = 0,
    this.hasgrad = false,
    this.isactive = true,
    this.mTop = 0,
    this.fontWeight,
    this.hasiconRight = false,
  });

  final String buttonText;
  final VoidCallback onTap;
  final double? height;
  final Widget? customChild; // Added
  final double? width;
  final double radius;
  final double? fontSize;
  final Color outlineColor;
  final bool hasicon,
      hasiconRight,
      isRight,
      isleft,
      hasshadow,
      hasgrad,
      isactive;
  final Color? backgroundColor, fontColor;
  final String? svgIcon, choiceIcon, choiceIconRight;
  final bool haveSvg;
  final double mTop, mBottom, mhoriz;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 1000)),
        MoveEffect(curve: Curves.fastLinearToSlowEaseIn),
      ],
      child: Bounce(
        duration: Duration(milliseconds: isactive ? 100 : 0),
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(
            top: mTop,
            bottom: mBottom,
            left: mhoriz,
            right: mhoriz,
          ),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: isactive
                ? backgroundColor ?? kPrimaryColor
                : backgroundColor ?? const Color(0xff0E1A34).withOpacity(0.35),

            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: outlineColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: customChild != null
                ? customChild!
                : AnimatedRow(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasicon)
                        Padding(
                          padding: isleft
                              ? const EdgeInsets.only(left: 20.0)
                              : const EdgeInsets.only(right: 0),
                          child: CommonImageView(
                            imagePath: choiceIcon,
                            height: 20,
                          ),
                        ),
                      MyText(
                        paddingLeft: hasicon ? 10 : 0,
                        text: buttonText,
                        size: fontSize ?? 16,

                        letterSpacing: 0.5,
                        color: fontColor ?? kWhite,
                        weight: fontWeight ?? FontWeight.w500,
                      ),
                      if (hasiconRight)
                        Padding(
                          padding: isRight
                              ? const EdgeInsets.only(left: 10.0)
                              : const EdgeInsets.only(right: 0),
                          child: CommonImageView(
                            imagePath: choiceIconRight,
                            height: 20,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
