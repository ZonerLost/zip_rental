import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_row.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

// ... (other imports remain the same)
class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.bgColor,
    this.marginBottom,
    this.width,
    this.labelText,
    this.prefixIcon, // Add prefixIcon parameter
  });

  final List<dynamic>? items;
  final String selectedValue;
  final ValueChanged<dynamic>? onChanged;
  final String hint;
  final String? labelText;
  final Color? bgColor;
  final double? marginBottom, width;
  final Widget? prefixIcon; // Add prefixIcon property

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? 16),
      child: Animate(
        effects: [
          MoveEffect(
            duration: Duration(milliseconds: 500),
            begin: const Offset(20, 0),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (labelText != null)
              Animate(
                effects: [
                  MoveEffect(
                    duration: Duration(milliseconds: 500),
                    begin: const Offset(20, 0),
                  ),
                ],
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    items: items!
                        .map(
                          (item) => DropdownMenuItem<dynamic>(
                            value: item,
                            child: MyText(
                              text: item,
                              size: 12,
                              color: kBlack,
                              weight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                    value: selectedValue == hint ? null : selectedValue,
                    hint: MyText(
                      text: hint,
                      size: 12,
                      color: kSubText2,
                      textAlign: TextAlign.start,
                      weight: FontWeight.w500,
                    ),
                    onChanged: onChanged,
                    iconStyleData: const IconStyleData(icon: SizedBox()),
                    isDense: true,
                    isExpanded: true,
                    customButton: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      height: 58,
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Animate(
                            effects: [
                              MoveEffect(
                                duration: Duration(milliseconds: 500),
                                begin: const Offset(20, 0),
                              ),
                            ],
                            child: MyText(
                              text: labelText!,
                              size: 12,
                              color: kSubText,
                              textAlign: TextAlign.start,
                              weight: FontWeight.w600,
                            ),
                          ),
                          AnimatedRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (prefixIcon != null) ...[
                                    prefixIcon!,
                                    SizedBox(
                                      width: 8,
                                    ), // Space between prefix and text
                                  ],
                                  MyText(
                                    paddingLeft: 8,
                                    text: selectedValue == hint
                                        ? hint
                                        : selectedValue,
                                    size: 16,
                                    color: kBlack,
                                    weight: FontWeight.w400,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  CommonImageView(
                                    imagePath: Assets.imagesArrowDown,
                                    height: 24,
                                  ),
                                  Gap(16),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(height: 35),
                    dropdownStyleData: DropdownStyleData(
                      elevation: 6,
                      maxHeight: 300,
                      offset: const Offset(0, -5),
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorderColor),
                        borderRadius: BorderRadius.circular(10),
                        color: kWhite,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomDropDown2 extends StatelessWidget {
  const CustomDropDown2({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.bgColor,
    this.marginBottom,
    this.width,
    this.labelText,
    this.prefixIcon,
  });

  final List<dynamic>? items;
  final String selectedValue;
  final ValueChanged<dynamic>? onChanged;
  final String hint;
  final String? labelText;
  final Color? bgColor;
  final double? marginBottom, width;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? 16),
      child: Animate(
        effects: const [
          MoveEffect(
            duration: Duration(milliseconds: 500),
            begin: Offset(20, 0),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (labelText != null)
              Animate(
                effects: const [
                  MoveEffect(
                    duration: Duration(milliseconds: 500),
                    begin: Offset(20, 0),
                  ),
                ],
                child: MyText(
                  paddingBottom: 10,
                  text: labelText!,
                  size: 16,
                  color: kBlack,
                  textAlign: TextAlign.start,
                  weight: FontWeight.w600,
                ),
              ),
            Animate(
              effects: const [
                MoveEffect(
                  duration: Duration(milliseconds: 500),
                  begin: Offset(20, 0),
                ),
              ],
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  items: items!
                      .map(
                        (item) => DropdownMenuItem<dynamic>(
                          value: item,
                          child: MyText(
                            text: item,
                            size: 12,
                            color: kBlack,
                            weight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                  value: selectedValue == hint ? null : selectedValue,
                  hint: MyText(
                    text: hint,
                    size: 12,
                    color: kSubText2,
                    textAlign: TextAlign.start,
                    weight: FontWeight.w500,
                  ),
                  onChanged: onChanged,
                  iconStyleData: const IconStyleData(icon: SizedBox()),
                  isDense: true,
                  isExpanded: true,
                  customButton: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    height: 58,
                    width: width,
                    decoration: BoxDecoration(
                      color: bgColor ?? kWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorderColor),
                    ),
                    child: AnimatedRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (prefixIcon != null) ...[
                              prefixIcon!,
                              const SizedBox(width: 8),
                            ],
                            MyText(
                              paddingLeft: 8,
                              text: selectedValue == hint
                                  ? hint
                                  : selectedValue,
                              size: 14,
                              color: kBlack,
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CommonImageView(
                              imagePath: Assets.imagesArrowDown,
                              height: 24,
                            ),
                            const Gap(16),
                          ],
                        ),
                      ],
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(height: 35),
                  dropdownStyleData: DropdownStyleData(
                    elevation: 6,
                    maxHeight: 300,
                    offset: const Offset(0, -5),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorderColor),
                      borderRadius: BorderRadius.circular(10),
                      color: kWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
