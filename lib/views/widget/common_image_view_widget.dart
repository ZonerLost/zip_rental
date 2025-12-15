import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:svg_flutter/svg.dart';
import 'package:shimmer/shimmer.dart';

class CommonImageView extends StatelessWidget {
  // ignore_for_file: must_be_immutable
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  double? height;
  double? width;
  double? radius;
  final BoxFit fit;
  final String placeHolder;

  CommonImageView({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return Animate(
        effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius!),
            child: SvgPicture.asset(
              svgPath!,
              height: height,
              width: width,
              fit: fit,
            ),
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return Animate(
        effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: Image.file(file!, height: height, width: width, fit: fit),
        ),
      );
    } else if (url != null && url!.isNotEmpty) {
      return Animate(
        effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: url!,
            placeholder:
                (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: height ?? 60,
                    width: width ?? 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(radius ?? 0.0),
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
                  height: 60,
                  width: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error, color: Colors.red),
                ),
          ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Animate(
        effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    }
    return const SizedBox();
  }
}

class CommonImageViewWithBorder extends StatelessWidget {
  final String? url;
  final String? imagePath;
  final String? svgPath;
  final File? file;
  final double? height;
  final double? width;

  /// Default uniform radius
  final double? radius;

  /// Individual corner radii
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeftRadius;
  final double? bottomRightRadius;

  final BoxFit fit;
  final String placeHolder;

  const CommonImageViewWithBorder({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomLeftRadius,
    this.bottomRightRadius,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  BorderRadius get _borderRadius => BorderRadius.only(
        topLeft: Radius.circular(topLeftRadius ?? radius ?? 0),
        topRight: Radius.circular(topRightRadius ?? radius ?? 0),
        bottomLeft: Radius.circular(bottomLeftRadius ?? radius ?? 0),
        bottomRight: Radius.circular(bottomRightRadius ?? radius ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: SvgPicture.asset(
            svgPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: _borderRadius,
        child: Image.file(file!, height: height, width: width, fit: fit),
      );
    } else if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: _borderRadius,
        child: CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: url!,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: height ?? 60,
              width: width ?? 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: _borderRadius,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Image.asset(
            placeHolder,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: _borderRadius,
        child: Image.asset(imagePath!, height: height, width: width, fit: fit),
      );
    }
    return const SizedBox();
  }
}