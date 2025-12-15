// ignore_for_file: unnecessary_string_Nunitopolations

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_fonts.dart';

// ignore: must_be_immutable
class MyText extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final String text;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextDecoration decoration;
  final FontWeight? weight;
  final TextOverflow? textOverflow;
  final Color? color;
  final FontStyle? fontStyle;
  final VoidCallback? onTap;
  final Color decorationColor; // Add this

  final int? maxLines;
  final double? size;
  final double? lineHeight;
  final double? paddingTop;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final double? letterSpacing;

  const MyText({
    super.key,
    required this.text,
    this.size,
    this.lineHeight,
    this.maxLines = 100,
    this.decoration = TextDecoration.none,
    this.color,
    this.letterSpacing,
    this.weight = FontWeight.w400,
    this.textAlign,
    this.textOverflow,
    this.fontFamily,

    this.decorationColor = Colors.transparent, // Default to transparent

    this.paddingTop = 0,
    this.paddingRight = 0,
    this.paddingLeft = 0,
    this.paddingBottom = 0,
    this.onTap,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
      child: Padding(
        padding: EdgeInsets.only(
          top: paddingTop!,
          left: paddingLeft!,
          right: paddingRight!,
          bottom: paddingBottom!,
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(
              fontSize: size,
              color: color ?? kBlack,
              fontWeight: weight,
              decoration: decoration,
              decorationColor: decorationColor,
              decorationThickness: 2, // Apply the color here
              fontFamily: AppFonts.HelveticaNowDisplay,
              height: lineHeight ?? 0,
              fontStyle: fontStyle,
              letterSpacing: letterSpacing ?? 0,
            ),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: textOverflow,
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyGradeintText extends StatelessWidget {
  final String text;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextDecoration decoration;
  final FontWeight? weight;
  final TextOverflow? textOverflow;
  final Color? color;

  final FontStyle? fontStyle;
  final VoidCallback? onTap;
  List<Shadow>? shadow;
  final int? maxLines;
  final Paint? paint;
  final double? size;
  final double? lineHeight;
  final double? paddingTop;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final double? letterSpacing;

  MyGradeintText({
    super.key,
    required this.text,
    this.size,
    this.lineHeight,
    this.fontFamily,

    this.maxLines = 100,
    this.decoration = TextDecoration.none,
    this.color,
    this.paint,
    this.letterSpacing,
    this.weight = FontWeight.w400,
    this.textAlign,
    this.textOverflow,
    this.paddingTop = 0,
    this.paddingRight = 0,
    this.paddingLeft = 0,
    this.paddingBottom = 0,
    this.onTap,
    this.shadow,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GradientText(
        gradientType: GradientType.linear,
        colors: [
          Color.fromARGB(255, 22, 192, 96),
          Color.fromARGB(244, 1, 156, 68),
          Color.fromARGB(255, 4, 202, 4),
        ],
        text,
        style: TextStyle(
          foreground: paint,

          shadows: shadow,
          fontSize: size ?? 14,
          color: color ?? kBlack,
          fontWeight: weight,
          decoration: decoration,
          decorationColor: color,
          decorationThickness: 2,
          fontFamily: fontFamily,
          height: lineHeight,
          fontStyle: fontStyle,
          letterSpacing: 0.5,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: textOverflow,
      ),
    );
  }
}
