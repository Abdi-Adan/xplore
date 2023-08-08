import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shamiri/features/feature_onboarding/presentation/components/login_title.dart';

import '../../../application/core/themes/colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: XploreColors.white,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: XploreColors.white,
              systemNavigationBarColor: XploreColors.white,
              systemNavigationBarIconBrightness: Brightness.dark),
          title: Text(
            "Checkout",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: XploreColors.black),
          ),
          centerTitle: true,
          backgroundColor: XploreColors.white,
          leading: IconButton(
              onPressed: () => Get.back(),
              icon:
                  Icon(Icons.arrow_back_rounded, color: XploreColors.deepBlue)),
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header
                  ...titles(
                      context: context,
                      title: "Place \n",
                      subtitle: "Your Order",
                      extraHeading: "Add payment information"),

                  //  devlivery information
                  //  payment information
                  //  order confirmation
                ],
              ),
            ),
          ),
        ));
  }
}
