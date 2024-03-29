import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shamiri/core/domain/model/user_model.dart';
import 'package:shamiri/core/presentation/controller/auth_controller.dart';
import 'package:shamiri/core/utils/extensions/string_extensions.dart';
import 'package:shamiri/features/feature_merchant_store/domain/model/transaction_types.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/transaction_tag.dart';

import '../../../../application/core/themes/colors.dart';
import '../../../../core/presentation/components/show_alert_dialog.dart';
import '../../../../core/presentation/components/show_toast.dart';
import '../../../../domain/value_objects/app_spaces.dart';
import 'package:get/get.dart';

import '../../../feature_cart/domain/model/payment_types.dart';
import '../../../feature_home/presentation/controller/home_controller.dart';
import '../../domain/model/transaction_model.dart';

class TransactionCardMain extends StatefulWidget {
  final String buyerId;
  final String buyerIdFull;
  final TransactionTypes transactionType;
  final PaymentTypes transactionPaymentMethod;
  final List<TransactionModel> allTransactionsByBuyer;
  final Function(String customerName) onTap;

  const TransactionCardMain(
      {super.key,
      required this.buyerId,
      required this.buyerIdFull,
      required this.transactionType,
      required this.transactionPaymentMethod,
      required this.allTransactionsByBuyer,
      required this.onTap});

  @override
  State<TransactionCardMain> createState() => _TransactionCardMainState();
}

class _TransactionCardMainState extends State<TransactionCardMain> {
  late final AuthController _authController;
  late final HomeController _homeController;
  late final FToast _toast;

  @override
  void initState() {
    super.initState();

    _authController = Get.find<AuthController>();
    _homeController = Get.find<HomeController>();
    _toast = FToast();
    _toast.init(context);
  }

  String getUserName() {
    UserModel? userName = widget.buyerId.split(" ").toList()[0] == 'customer'
        ? null
        : _homeController.stores.firstWhereOrNull(
            (store) => store.userId! == widget.buyerId.split(" ").toList()[0]);

    final customerNumber = widget.buyerIdFull.split(" ").toList()[1];

    return userName == null ? 'Customer $customerNumber' : userName.userName!;
  }

  int getTotalPrice() {
    final allTransactionsPrice = _authController.user.value!.transactions!
        .where((transaction) =>
            transaction.buyerId!.formatBuyerId == widget.buyerId)
        .map((transaction) => transaction.amountPaid!)
        .reduce((value, element) => value + element);

    return allTransactionsPrice;
  }

  int getTotalItemsBought() {
    final allTransactionsItemsBought = _authController.user.value!.transactions!
        .where((transaction) =>
            transaction.buyerId!.formatBuyerId == widget.buyerId)
        .map((transaction) => transaction.itemsBought!)
        .reduce((value, element) => value + element);

    return allTransactionsItemsBought;
  }

  String getDateOfPurchase() {
    final transaction = _authController.user.value!.transactions!.firstWhere(
        (transaction) => transaction.buyerId!.formatBuyerId == widget.buyerId);

    return transaction.transactionCompletedDate!.isNotEmpty
        ? "Completed : ${transaction.transactionCompletedDate!.formatDate}"
        : "Created : ${transaction.transactionDate!.formatDate}";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap(getUserName()),
      child: Container(
        width: double.infinity,
        height: widget.transactionType == TransactionTypes.pending ||
                widget.transactionType == TransactionTypes.credit
            ? 120
            : 88,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: XploreColors.white),
        child: Container(
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: XploreColors.deepBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100)),
                      child:
                          widget.transactionPaymentMethod == PaymentTypes.mpesa
                              ? Image.asset(
                                  'assets/general/mpesa_new.png',
                                  fit: BoxFit.contain,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Icon(
                                    widget.transactionPaymentMethod ==
                                            PaymentTypes.cash
                                        ? Icons.payments_rounded
                                        : Icons.loyalty_rounded,
                                    color: XploreColors.deepBlue,
                                    size: 24,
                                  ),
                                ),
                    ),

                    hSize10SizedBox,

                    //  product name
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //  name and price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${getUserName()}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                //  price
                                Text(
                                  "Ksh. ${getTotalPrice().toString().addCommas}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "No category",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  "${getTotalItemsBought()} items",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              ],
                            ),

                            //  date and tags
                            Row(
                              children: [
                                Text(
                                  getDateOfPurchase(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                hSize20SizedBox,
                                TransactionTag(
                                    title: widget.transactionType ==
                                            TransactionTypes.fulfilled
                                        ? 'Complete'
                                        : widget.transactionType ==
                                                TransactionTypes.pending
                                            ? 'Pending'
                                            : 'Credit',
                                    tagColor: widget.transactionType ==
                                            TransactionTypes.fulfilled
                                        ? XploreColors.green
                                        : widget.transactionType ==
                                                TransactionTypes.pending
                                            ? XploreColors.red
                                            : XploreColors.xploreOrange)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: widget.transactionType == TransactionTypes.pending ||
                      widget.transactionType == TransactionTypes.credit,
                  child: Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: UnconstrainedBox(
                      child: GestureDetector(
                        onTap: () {
                          showAlertDialog(
                              title: "Complete Transaction",
                              iconData: Icons.receipt_rounded,
                              content: Text(
                                "Would you like to complete this transaction?",
                                textAlign: TextAlign.center,
                              ),
                              onCancel: () => Get.back(),
                              onConfirm: () async {
                                //  all transactions
                                final allTransactions =
                                    _authController.user.value!.transactions!;

                                allTransactions.forEach((transaction) {
                                  if (transaction.buyerId!.formatBuyerId ==
                                      widget.buyerIdFull.formatBuyerId) {
                                    transaction.transactionType =
                                        TransactionTypes.fulfilled.toString();
                                    transaction.transactionCompletedDate =
                                        DateTime.now().toString();
                                  }
                                });

                                await _authController.updateUserDataInFirestore(
                                    oldUser: _authController.user.value!,
                                    newUser: UserModel(
                                        transactions: allTransactions),
                                    uid: _authController.user.value!.userId!,
                                    response: (state, error) {});

                                showToast(
                                    toast: _toast,
                                    iconData: Icons.done_rounded,
                                    msg: 'Transaction completed successfully!');

                                Get.back();
                              });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: XploreColors.deepBlue,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.transactionType ==
                                        TransactionTypes.pending
                                    ? Icons.done_rounded
                                    : Icons.attach_money_rounded,
                                color: XploreColors.white,
                                size: 16,
                              ),
                              hSize10SizedBox,
                              Text(
                                widget.transactionType ==
                                        TransactionTypes.pending
                                    ? "Complete"
                                    : "Pay",
                                style: TextStyle(
                                    fontSize: 14, color: XploreColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
