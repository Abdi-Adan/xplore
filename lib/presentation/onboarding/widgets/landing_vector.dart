import 'package:flutter/material.dart';
import 'package:xplore/domain/value_objects/app_asset_strings.dart';

class LandingVector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 250,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(landingVectorImage),
        ),
      ),
    );
  }
}