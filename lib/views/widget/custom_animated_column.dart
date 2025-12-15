import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedColumn extends StatelessWidget {
  const AnimatedColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize,
    this.spacing,
    this.textBaseline,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.animationDuration,
  });

  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final double? spacing;
  final CrossAxisAlignment? crossAxisAlignment;
  final int? animationDuration;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        MoveEffect(
          duration: Duration(milliseconds: animationDuration ?? 1000),
          begin: const Offset(0, 20),
        ),
      ],
      child: Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        children: spacing != null ? _addSpacing(children, spacing!) : children,
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i != children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}

class AnimatedListView extends StatelessWidget {
  const AnimatedListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.animationDuration,
    this.shrinkWrap = false,
    this.primary,
    this.reverse = false,
    this.physics,
    this.controller,
    this.itemExtent,
    this.textDirection,
    this.cacheExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final int? animationDuration;

  // Additional parameters for ListView
  final bool shrinkWrap;
  final bool? primary;
  final bool reverse;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final double? itemExtent;
  final TextDirection? textDirection;
  final double? cacheExtent;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      scrollDirection: scrollDirection,
      padding: padding,
      shrinkWrap: shrinkWrap,
      primary: primary,
      reverse: reverse,
      physics: physics ?? const BouncingScrollPhysics(),
      controller: controller,
      itemExtent: itemExtent,
      cacheExtent: cacheExtent,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      itemBuilder: (context, index) {
        return children[index]
            .animate()
            .move(
              duration: Duration(milliseconds: animationDuration ?? 1000),
              begin: const Offset(0, 20),
            )
            .fade(duration: Duration(milliseconds: animationDuration ?? 1000));
      },
    );
  }
}
