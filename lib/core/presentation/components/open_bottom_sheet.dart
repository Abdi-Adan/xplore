import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamiri/application/core/themes/colors.dart';

void openBottomSheet(
        {required Widget content,
        required VoidCallback onComplete,
        double height = 400,
        bool isElevated = false}) =>
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      showDragHandle: isElevated ? false : true,
      isScrollControlled: true,
      backgroundColor: isElevated
          ? Colors.transparent
          : XploreColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      context: Get.context!,
      builder: (context) => isElevated
          ? Container(
              height: height,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: XploreColors.white,
              ),
              child: content,
            )
          : content,
    ).whenComplete(() => onComplete());
