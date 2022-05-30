// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:shamiri/application/singletons/sliding_tab_status.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/infrastructure/remote_repository/firestore_db.dart';
import 'package:shamiri/presentation/dashboard/widgets/layout/dashboard_shimmer.dart';
import 'package:shamiri/presentation/dashboard/widgets/layout/sliding_tab.dart';
import 'package:shamiri/presentation/dashboard/widgets/molecular/transaction_card.dart';

class MerchantRecords extends StatefulWidget {
  const MerchantRecords({Key? key}) : super(key: key);

  @override
  State<MerchantRecords> createState() => _MerchantRecordsState();
}

class _MerchantRecordsState extends State<MerchantRecords> {
  @override
  Widget build(BuildContext context) {
    Database transactionRepositoryInstance = Database();
    SlidingTabStatusStore transactionTabState = SlidingTabStatusStore();

    return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(children: <Widget>[
          vSize10SizedBox,
          Container(
            width: double.infinity,
            child: SlidingTabs(
              selectedTab: transactionTabState.activeTabState.value,
              tabs: [
                SlidingTab(
                  key: const ValueKey("TransactionOverview_PendingTab"),
                  title: Text('Pending'),
                ),
                SlidingTab(
                  key: const ValueKey("TransactionOverview_FulfilledTab"),
                  title: Text('Fulfilled'),
                ),
              ],
              onTabChanged: (v) {
                print('Tab changed to $v');
                setState(() {
                  transactionTabState.activeTabState.add(v ?? 0);
                });
              },
            ),
          ),
          vSize10SizedBox,
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
                stream: transactionRepositoryInstance.getStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(child: Text('Something went wrong')));
                  } else if (snapshot.hasData || snapshot.data != null) {
                    return Container(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext ctx, index) {
                          String name = snapshot.data!.docs[index]["name"];
                          String qty = snapshot.data!.docs[index]["quantity"];
                          return Transactioncard(
                            name: name,
                            quantity: qty,
                          );
                        },
                      ),
                    );
                  }
                  return DashboardShimmer();
                }),
          )
        ]));
  }
}
