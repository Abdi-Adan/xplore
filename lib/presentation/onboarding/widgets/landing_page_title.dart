import 'package:flutter/material.dart';
import 'package:xplore/application/core/themes/colors.dart';
import 'package:xplore/domain/value_objects/app_spaces.dart';

class LandingPageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: 'Fast \n',
              style: TextStyle(
                  color: XploreColors.black,
                  fontSize: 55,
                  fontWeight: FontWeight.bold),
              children: const <TextSpan>[
                TextSpan(
                    text: '   & ',
                    style: TextStyle(
                      color: XploreColors.orange,
                      fontSize: 48,
                      fontWeight: FontWeight.normal,
                    )),
                TextSpan(
                  text: 'Digital.',
                  style: TextStyle(
                    color: XploreColors.black,
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          hSize30SizedBox,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Keep your store in order , Easy to use  point of sale',
              style: TextStyle(
                color: XploreColors.orange,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
