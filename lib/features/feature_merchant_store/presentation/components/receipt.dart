import 'package:flutter/material.dart';
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/core/utils/extensions/string_extensions.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/features/feature_cart/domain/model/payment_types.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/transaction_card.dart';

import '../../domain/model/transaction_model.dart';
import '../../domain/model/transaction_types.dart';

class Receipt extends StatelessWidget {
  final String userName;
  final String totalPrice;
  final List<TransactionModel> allTransactionsByBuyer;

  const Receipt(
      {super.key,
      required this.userName,
      required this.totalPrice,
      required this.allTransactionsByBuyer});

  TransactionTypes getTransactionType({required int index}) {
    final transaction = allTransactionsByBuyer[index];

    return TransactionTypes.values
        .firstWhere((type) => type.toString() == transaction.transactionType!);
  }

  PaymentTypes getPaymentType({required int index}) {
    final transaction = allTransactionsByBuyer[index];

    return PaymentTypes.values.firstWhere(
        (type) => type.toString() == transaction.transactionPaymentMethod!);
  }

  String getCreatedDate() {
    final transaction = allTransactionsByBuyer[0];

    return transaction.transactionCompletedDate!.isNotEmpty
        ? "Completed : ${transaction.transactionCompletedDate!.formatDate}"
        : "Created : ${transaction.transactionDate!.formatDate}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: XploreColors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //  logo
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        "assets/appIcon/playstore.png",
                        width: 60,
                        height: 60,
                      )),
                  vSize20SizedBox,
                  Text(
                    "Order ${getTransactionType(index: 0) == TransactionTypes.fulfilled ? "complete!" : getTransactionType(index: 0) == TransactionTypes.pending ? "pending!" : "on credit!"}",
                    style: TextStyle(
                        color: XploreColors.deepBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                ],
              ),
            ),

            //  notch divider
            Row(
              children: [
                Container(
                    width: 10,
                    height: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100)),
                        color: XploreColors.deepBlue)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                        20,
                        (index) => Container(
                              width: 8,
                              height: 2,
                              color: XploreColors.deepBlue,
                            )),
                  ),
                ),
                Container(
                  width: 10,
                  height: 20,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          bottomLeft: Radius.circular(100)),
                      color: XploreColors.deepBlue),
                ),
              ],
            ),

            vSize20SizedBox,

            //  username title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  userName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: XploreColors.black),
                ),
              ),
            ),

            vSize20SizedBox,

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final transaction = allTransactionsByBuyer[index];

                    return TransactionCard(
                      transaction: transaction,
                      product: transaction.product!,
                      altColors: false,
                      transactionType: getTransactionType(index: index),
                      transactionPaymentMethod: getPaymentType(index: index),
                    );
                  },
                  itemCount: allTransactionsByBuyer.length),
            ),

            //  total divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 5,
                color: XploreColors.deepBlue,
              ),
            ),

            vSize20SizedBox,

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                  height: 80,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                              Text(
                                "Ksh. $totalPrice",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          vSize20SizedBox,
                          Text(
                            getCreatedDate(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: XploreColors.deepBlue.withOpacity(0.8)),
                          ),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                              10,
                              (index) => Container(
                                    width: 20,
                                    height: 10,
                                    margin: index != 9
                                        ? const EdgeInsets.only(right: 8)
                                        : EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: XploreColors.deepBlue,
                                    ),
                                  )),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
