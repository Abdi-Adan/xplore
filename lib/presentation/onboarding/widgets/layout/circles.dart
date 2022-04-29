// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:xplore/application/core/themes/colors.dart';

List<Widget> circles(BuildContext context, Color? circleColor) {
  const double diagonalCircleDiameter = 350;
  const double circleSize = 1000;
  const double circleOffscreenSize = -500;
  return <Widget>[
    Positioned(
      top: circleOffscreenSize,
      left: circleOffscreenSize,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circleColor ?? XploreColors.whiteSmoke,
        ),
      ),
    ),
    Positioned.fill(
      top: -(diagonalCircleDiameter /2),
      left: -(diagonalCircleDiameter /2),
      child: Container(
        width: diagonalCircleDiameter,
        height: diagonalCircleDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: XploreColors.orange,
        ),
      ),
    ),
  ];
}
