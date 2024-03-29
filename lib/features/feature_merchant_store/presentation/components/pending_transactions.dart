import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shamiri/core/utils/extensions/string_extensions.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/transaction_card_main.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/transaction_receipt_screen.dart';

import '../../../../core/presentation/components/my_lottie.dart';
import '../../../../core/presentation/controller/auth_controller.dart';
import '../../../feature_cart/domain/model/payment_types.dart';
import '../../../feature_home/presentation/controller/home_controller.dart';
import '../../domain/model/transaction_types.dart';

class PendingTransactions extends StatefulWidget {
  const PendingTransactions({super.key});

  @override
  State<PendingTransactions> createState() => _PendingTransactionsState();
}

class _PendingTransactionsState extends State<PendingTransactions> {
  late final HomeController _homeController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();

    _homeController = Get.find<HomeController>();
    _authController = Get.find<AuthController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pendingTransactionsByBuyerId = _authController
          .user.value!.transactions!
          .where((transaction) =>
              transaction.transactionType ==
              TransactionTypes.pending.toString())
          .map((transaction) => transaction.buyerId!.formatBuyerId)
          .toSet()
          .toList();

      final pendingTransactionsByBuyerIdFull = _authController
          .user.value!.transactions!
          .where((transaction) =>
      transaction.transactionType ==
          TransactionTypes.pending.toString())
          .map((transaction) => transaction.buyerId!)
          .toSet()
          .toList();

      return pendingTransactionsByBuyerId.isNotEmpty
          ? SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, mainIndex) {
                final allTransactionsByBuyer = _authController
                    .user.value!.transactions!
                    .where((transaction) =>
                        transaction.buyerId!.formatBuyerId ==
                            pendingTransactionsByBuyerId[mainIndex] &&
                        transaction.transactionType ==
                            TransactionTypes.pending.toString())
                    .toList();

                final getPaymentMethod = allTransactionsByBuyer
                    .map((transaction) => transaction.transactionPaymentMethod!)
                    .toList();

                final paymentType = PaymentTypes.values.firstWhere(
                    (type) => type.toString() == getPaymentMethod[0]);

                return TransactionCardMain(
                  buyerId: pendingTransactionsByBuyerId[mainIndex],
                  buyerIdFull: pendingTransactionsByBuyerIdFull[mainIndex],
                  transactionType: TransactionTypes.pending,
                  transactionPaymentMethod: paymentType,
                  allTransactionsByBuyer: allTransactionsByBuyer,
                  onTap: (customer) {
                    Get.to(() => TransactionReceiptScreen(
                          allTransactionsByBuyer: allTransactionsByBuyer,
                          customerName: customer,
                        ));
                  },
                );
              }, childCount: pendingTransactionsByBuyerId.length)),
            )
          : SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyLottie(
                    lottie: 'assets/general/receipt.json',
                  ),
                  Text("No pending transactions")
                ],
              ),
            );
    });
  }
}
