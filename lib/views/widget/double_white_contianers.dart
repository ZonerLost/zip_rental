import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';

class DoubleWhiteContainers extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final Color? mainColor;
  final Color? topColor;
  final BorderRadius? borderRadius;
  final double? handleHeight; // 👈 Added

  const DoubleWhiteContainers({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.mainColor,
    this.topColor,
    this.borderRadius,
    this.handleHeight, // 👈 Added
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Get.height,
      width: width ?? Get.width,
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: Get.height,
              decoration: BoxDecoration(
                color: mainColor ?? Colors.white,
                borderRadius:
                    borderRadius ??
                    const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
              ),
            ),
          ),

          // Drag handle
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              height: handleHeight ?? 10, // 👈 adjustable handle height
              decoration: BoxDecoration(
                color: topColor ?? kWhite.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Custom Content
          Positioned.fill(
            top: 40,
            child: Padding(padding: AppSizes.DEFAULT, child: child),
          ),
        ],
      ),
    );
  }
}

class DoubleWhiteContainers2 extends StatelessWidget {
  final Widget child;
  final double? handleHeight; // 👈 Added

  const DoubleWhiteContainers2({
    super.key,
    required this.child,
    this.handleHeight, // 👈 Added
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: Get.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // Drag handle
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: handleHeight ?? 10, // 👈 adjustable handle height
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // Custom Content
          Positioned.fill(
            top: 30,
            child: Padding(padding: AppSizes.DEFAULT, child: child),
          ),
        ],
      ),
    );
  }
}
