import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_row.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class SelectableListView extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String?
  selectedOption; // Add this to control the selected option from parent

  const SelectableListView({
    super.key,
    required this.options,
    required this.onSelected,
    this.selectedOption, // Pass the selected option from parent
  });

  @override
  _SelectableListViewState createState() => _SelectableListViewState();
}

class _SelectableListViewState extends State<SelectableListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        final option = widget.options[index];
        final isSelected =
            widget.selectedOption ==
            option; // Use the passed in selected option

        return GestureDetector(
          onTap: () {
            widget.onSelected(option);
          },
          child: Container(
            height: 65,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? kPrimaryColor : kBorderColor,
                width: isSelected ? 2 : 1,
              ),
              gradient: isSelected ? kContainerBackgroundGradeintColor : null,
              color: isSelected ? null : kWhite,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? kWhite : kStroke,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? kWhite : kDividerColor,
                  ),
                  child: isSelected
                      ? const Icon(Icons.circle, color: kPrimaryColor, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                MyText(
                  text: option,
                  size: 14,
                  weight: FontWeight.w500,
                  color: isSelected ? kWhite : kBlackText,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectableRadioListView extends StatefulWidget {
  final List<String> options;
  final List<String> imagePath;
  final ValueChanged<String> onSelected;
  final String? selectedOption;

  const SelectableRadioListView({
    super.key,
    required this.options,
    required this.imagePath,
    required this.onSelected,
    this.selectedOption,
  });

  @override
  _SelectableRadioListViewState createState() =>
      _SelectableRadioListViewState();
}

class _SelectableRadioListViewState extends State<SelectableRadioListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        final option = widget.options[index];
        final imagePath = widget.imagePath[index];
        final isSelected = widget.selectedOption == option;

        return Bounce(
          onTap: () {
            widget.onSelected(option);
          },
          child: AnimatedRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Gradient Border
                  Container(
                    height: 20,
                    width: 20,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: kWhite,
                      border: Border.all(
                        color: isSelected ? kgreenColor : kTransperentColor,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                  ),

                  // Inner Container (Actual Circle)
                  Container(
                    height: 18,
                    width: 18,
                    margin: const EdgeInsets.only(bottom: 10),

                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : kGreyColor6,
                    ),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return isSelected
                            ? const LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds)
                            : const LinearGradient(
                                colors: [
                                  kGreyColor6,
                                  kGreyColor6,
                                ], // Keeps it grey when not selected
                              ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.circle,
                        color: isSelected
                            ? Colors.white
                            : kGreyColor6, // Grey when not selected
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              CommonImageView(imagePath: imagePath, height: 18),
              const SizedBox(width: 8),
              MyText(
                text: option,
                size: 14,
                weight: FontWeight.w500,
                color: kBlackText,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        );
      },
    );
  }
}
