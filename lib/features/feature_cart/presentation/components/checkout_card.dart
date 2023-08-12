import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shamiri/core/presentation/components/submit_button.dart';
import 'package:shamiri/core/utils/extensions/string_extensions.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/features/feature_checkout/presentation/checkout_screen.dart';

import '../../../../application/core/themes/colors.dart';
import '../../../../core/presentation/controller/auth_controller.dart';
import '../../../feature_home/presentation/controller/home_controller.dart';

class CheckoutCard extends StatefulWidget {
  const CheckoutCard({super.key});

  @override
  State<CheckoutCard> createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<CheckoutCard> {
  late final AuthController _authController;
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();

    _authController = Get.find();
    _homeController = Get.find();
  }

  int getTotalAmount() {
    if (_homeController.products.isEmpty) {
      return 0;
    }

    final itemsInCart = _authController.user.value!.itemsInCart!;
    var total = 0;

    itemsInCart.forEach((item) {
      total += item.cartProductCount! *
          _homeController.products
              .firstWhere(
                  (product) => product.productId! == item.cartProductId!)
              .productSellingPrice!;
    });

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        color: XploreColors.deepBlue,
      ),
      child: Wrap(
        runSpacing: 24,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: XploreColors.xploreOrange,
              ),
              hSize10SizedBox,
              Text("Order Summary",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: XploreColors.white)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal",
                  style: TextStyle(
                      fontSize: 18,
                      color: XploreColors.whiteSmoke,
                      fontWeight: FontWeight.bold)),
              Obx(() => Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Ksh. ",
                        style: TextStyle(
                            fontSize: 18,
                            color: XploreColors.whiteSmoke,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "${getTotalAmount().toString().addCommas}",
                        style: TextStyle(
                            fontSize: 21,
                            color: XploreColors.white,
                            fontWeight: FontWeight.bold)),
                  ]))),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total",
                  style: TextStyle(
                      fontSize: 18,
                      color: XploreColors.white,
                      fontWeight: FontWeight.bold)),
              Obx(() => Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "Ksh. ",
                        style: TextStyle(
                            fontSize: 18,
                            color: XploreColors.whiteSmoke,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "${getTotalAmount().toString().addCommas}",
                        style: TextStyle(
                            fontSize: 21,
                            color: XploreColors.white,
                            fontWeight: FontWeight.bold)),
                  ]))),
            ],
          ),

          //  checkout button
          SubmitButton(
              iconData: Icons.shopping_bag_rounded,
              text: "Checkout",
              backgroundColor: XploreColors.xploreOrange,
              isValid: true,
              onTap: () => Get.to(() => CheckoutScreen(
                    totalToPay: getTotalAmount().toString().addCommas,
                  )))
        ],
      ),
    );
  }
}
