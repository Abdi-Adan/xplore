import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../application/core/themes/colors.dart';

class ProductImage extends StatelessWidget {
  final String? filePath;
  final String? url;
  final bool isDeleteInProgress;
  final VoidCallback onDelete;

  const ProductImage(
      {super.key,
      this.filePath,
      this.url,
      this.isDeleteInProgress = false,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Opacity(
        opacity: isDeleteInProgress ? 0.4 : 1,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: XploreColors.white),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: filePath == null
                    ? CachedNetworkImage(
                        imageUrl: url!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        File(filePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
              //  delete icon
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: UnconstrainedBox(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: XploreColors.white,
                              width: 5,
                              strokeAlign: BorderSide.strokeAlignOutside),
                          color: XploreColors.deepBlue),
                      child: Center(
                        child: Icon(
                          Icons.delete_forever_rounded,
                          color: XploreColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
