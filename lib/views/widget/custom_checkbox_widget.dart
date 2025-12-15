import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/custom_animated_row.dart';

import 'my_text_widget.dart';

class CustomCheckbox extends StatefulWidget {
  final String? text;
  final String? text2;

  final Color? textcolor;
  final Function(bool) onChanged;

  const CustomCheckbox({
    super.key,
    this.text,
    this.text2,

    required this.onChanged,
    this.textcolor,
  });

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              color: _isChecked ? kPrimaryColor : kWhite,
              border: Border.all(
                color: _isChecked ? kPrimaryColor : kWhite,
                width: 1,
              ),
            ),
            child: _isChecked
                ? const Icon(Icons.check, color: kWhite, size: 16)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AnimatedRow(
              spacing: 4,
              children: [
                MyText(
                  text: widget.text ?? '',
                  size: 16,
                  letterSpacing: 0,
                  color: widget.textcolor ?? kBlack,
                  weight: FontWeight.w500,
                ),
                MyText(
                  text: widget.text2 ?? '',
                  size: 16,
                  color: kPrimaryColor,
                  decoration: TextDecoration.underline,

                  decorationColor: kPrimaryColor,

                  letterSpacing: 0,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCheckbox2 extends StatefulWidget {
  final String? text;
  final String? text2;

  final Color? textcolor;
  final Function(bool) onChanged;

  const CustomCheckbox2({
    super.key,
    this.text,
    this.text2,

    required this.onChanged,
    this.textcolor,
  });

  @override
  State<CustomCheckbox2> createState() => _CustomCheckbox2State();
}

class _CustomCheckbox2State extends State<CustomCheckbox2> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      child: AnimatedRow(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: _isChecked ? kPrimaryColor : kbackground,
            ),
            child: _isChecked
                ? const Icon(Icons.check, color: kWhite, size: 10)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AnimatedRow(
              spacing: 4,
              children: [
                MyText(
                  text: widget.text ?? '',
                  size: 14,
                  letterSpacing: 0,
                  color: kSubText,
                  weight: FontWeight.w500,
                ),
                MyText(
                  text: widget.text2 ?? '',
                  size: 14,
                  letterSpacing: 0,

                  weight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCheckbox3 extends StatefulWidget {
  final String? text;
  final String? text2;

  final Color? textcolor;
  final Function(bool) onChanged;

  const CustomCheckbox3({
    super.key,
    this.text,
    this.text2,

    required this.onChanged,
    this.textcolor,
  });

  @override
  _CustomCheckbox3State createState() => _CustomCheckbox3State();
}

class _CustomCheckbox3State extends State<CustomCheckbox3> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      child: AnimatedRow(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              color: _isChecked ? kPrimaryColor : kWhite,
              border: Border.all(
                color: _isChecked ? kPrimaryColor : kWhite,
                width: 1,
              ),
            ),
            child: _isChecked
                ? const Icon(Icons.check, color: kWhite, size: 16)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AnimatedRow(
              spacing: 4,
              children: [
                MyText(
                  text: widget.text ?? '',
                  size: 14,
                  letterSpacing: 0,
                  textOverflow: TextOverflow.fade,

                  color: widget.textcolor ?? kBlack,
                  weight: FontWeight.w500,
                ),
                MyText(
                  text: widget.text2 ?? '',
                  size: 14,
                  color: kPrimaryColor,
                  decoration: TextDecoration.underline,

                  decorationColor: kPrimaryColor,
                  textOverflow: TextOverflow.fade,

                  letterSpacing: 0,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
