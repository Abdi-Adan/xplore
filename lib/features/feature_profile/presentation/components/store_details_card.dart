import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shamiri/core/domain/model/user_model.dart';
import 'package:shamiri/features/feature_onboarding/presentation/screens/create_profile_page.dart';

import '../../../../application/core/themes/colors.dart';
import '../../../../domain/value_objects/app_spaces.dart';

class StoreDetailsCard extends StatelessWidget {
  final UserModel user;

  const StoreDetailsCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 300,
        height: 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //  title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: XploreColors.deepBlue,
                      size: 20,
                    ),
                    hSize10SizedBox,
                    Text(
                      "Store Details",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: XploreColors.deepBlue),
                    ),
                  ],
                ),

                //  edit icon
                GestureDetector(
                  onTap: () => Get.to(() => CreateProfilePage(currentUser: user,)),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: XploreColors.xploreOrange),
                    child: Center(
                      child: Icon(
                        Icons.edit_rounded,
                        color: XploreColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),

            vSize10SizedBox,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //  store name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Store Name"),
                      Text(user.storeName!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),

                //  store name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Store Location"),
                      Text(user.storeLocation!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
