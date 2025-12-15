
import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1.0,
    this.color = Colors.grey,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}



class DottedLine extends StatelessWidget {
  final Axis direction;
  final double length;
  final double thickness;
  final Color color;
  final double gap;

  const DottedLine({
    super.key,
    this.direction = Axis.horizontal,
    required this.length,
    this.thickness = 1,
    this.color = Colors.brown,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: direction == Axis.horizontal ? length : thickness,
      height: direction == Axis.vertical ? length : thickness,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int count = (direction == Axis.horizontal
                  ? (constraints.maxWidth / (gap * 2)).floor()
                  : (constraints.maxHeight / (gap * 2)).floor())
              .toInt();

          return Flex(
            direction: direction,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (index) {
              return SizedBox(
                width: direction == Axis.horizontal ? gap : thickness,
                height: direction == Axis.vertical ? gap : thickness,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
