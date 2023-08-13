import 'package:flutter/material.dart';

import '../../../../core/presentation/components/my_lottie.dart';

class PendingTransactions extends StatefulWidget {
  const PendingTransactions({super.key});

  @override
  State<PendingTransactions> createState() => _PendingTransactionsState();
}

class _PendingTransactionsState extends State<PendingTransactions> {
  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyLottie(
            lottie: 'assets/general/receipt.json',
          ),
          Text("No pending transactions yet.")
        ],
      ),
    );
  }
}
