// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:shamiri/application/core/themes/colors.dart';

class CustomFAB extends StatelessWidget {
  final IconData actionIcon;
  final String actionLabel;
  final Color color;
  final String? tag;
  final void Function()? onPressed;

  const CustomFAB({
    Key? key,
    required this.actionIcon,
    required this.actionLabel,
    this.tag,
    this.color = XploreColors.deepBlue,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FloatingActionButton.extended(
        backgroundColor: XploreColors.deepBlue,
        heroTag: tag,
        onPressed: onPressed,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              actionIcon,
              size: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(actionLabel,
                style: TextStyle(
                  fontSize: 14,
                )),
          ],
        ),
        enableFeedback: true,
      ),
    );
  }
}
