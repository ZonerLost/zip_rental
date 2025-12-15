// Dot indicator Widget
import 'package:flutter/material.dart';
import 'package:zip_peer/constants/app_colors.dart';

class DotIndicator extends StatelessWidget {
  final bool isActive;
  const DotIndicator({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: 10,
      width: isActive ? 10 : 10,
      decoration: BoxDecoration(
        color: isActive ? kPurple : kWhite,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
    );
  }
}
