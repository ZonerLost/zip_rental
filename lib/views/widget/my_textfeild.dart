import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class MyTextField extends StatefulWidget {
  final String? label, hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool? isObSecure, isReadOnly;
  final double? marginBottom, radius;
  final int? maxLines;
  final double? labelSize, hintsize;
  final FocusNode? focusNode;
  final Color? filledColor, focusedFillColor, hintColor, labelColor;
  final Widget? prefix, suffix;
  final FontWeight? labelWeight, hintWeight;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final double? height;
  final double? Width;
  final FormFieldValidator<String>? validator;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? errorText;
  final bool alwaysShowLabel;

  const MyTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 16.0,
    this.maxLines = 1,
    this.filledColor,
    this.focusedFillColor,
    this.hintColor,
    this.labelColor,
    this.labelSize,
    this.hintsize,
    this.prefix,
    this.suffix,
    this.labelWeight,
    this.hintWeight,
    this.keyboardType,
    this.isReadOnly,
    this.onTap,
    this.focusNode,
    this.radius,
    this.height = 56,
    this.Width,
    this.validator,
    this.backgroundColor,
    this.borderColor,
    this.errorText,
    this.alwaysShowLabel = true,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode?.hasFocus ?? false);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    final showLabel =
        widget.label != null &&
        (widget.alwaysShowLabel || _isFocused || hasText);

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
        MoveEffect(
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 400),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.marginBottom ?? 0),
        child: Container(
          width: widget.Width ?? double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? kWhite, // ✅ FIXED HERE
            borderRadius: BorderRadius.circular(widget.radius ?? 12),
            border: Border.all(
              color: _isFocused ? kPrimaryColor : Colors.transparent,
              width: _isFocused ? 2.0 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LABEL INSIDE RED CONTAINER
              if (showLabel)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 12, bottom: 4),
                  child: MyText(
                    text: widget.label!,
                    size: widget.labelSize ?? 13,
                    color: widget.labelColor ?? kBlack,
                    weight: widget.labelWeight ?? FontWeight.w500,
                  ),
                ),

              // TEXT FIELD
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
                child: TextFormField(
                  validator: widget.validator,
                  focusNode: widget.focusNode,
                  onTap: widget.onTap,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: widget.keyboardType,
                  cursorColor: kBlack,
                  maxLines: widget.maxLines ?? 1,
                  readOnly: widget.isReadOnly ?? false,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  obscureText: widget.isObSecure ?? false,
                  obscuringCharacter: '•',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: kBlack,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: widget.hintColor ?? kSubText,
                      fontWeight: widget.hintWeight ?? FontWeight.w600,
                    ),
                    prefixIcon: widget.prefix != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: widget.prefix,
                          )
                        : null,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    suffixIcon: widget.suffix,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
