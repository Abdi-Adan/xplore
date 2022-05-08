// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/presentation/core/widgets/xplore_appbar.dart';
import 'package:shamiri/presentation/dashboard/widgets/product_list.dart';
import 'package:shamiri/presentation/dashboard/widgets/transaction_list.dart';
import 'AddProducts.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int currentIndex = 0;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  // int pen = 0;

  // setIndex(i) {
  //   setState(() {
  //     pen = i;
  //   });
  // }

  late String sdefault;
  String cdefault = 'complete';

  void newDefault(value) {
    setState(() {
      sdefault = value;
    });
  }

  @override
  void initState() {
    super.initState();
    sdefault = 'pending';
  }

  @override
  Widget build(BuildContext context) {
    // Tabs created to display text on each screen

    final tabs = [
      Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          //color: Colors.green,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TextField(
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(20.0),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.deepOrange, width: 2.0),
                    borderRadius: BorderRadius.zero,
                  ),
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: Colors.deepOrange,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.deepOrange,
                  ),
                  hintText: "Search",
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AddProducts()));
                  },
                  child: Container(
                      height: 39,
                      width: MediaQuery.of(context).size.width * 0.4,
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                          'Add Product',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                      height: 39,
                      width: MediaQuery.of(context).size.width * 0.4,
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                          'Add Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: ProductList(),
            )
          ])),
      Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          //color: Colors.green,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TextField(
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(20.0),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.deepOrange, width: 2.0),
                    borderRadius: BorderRadius.zero,
                  ),
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: Colors.deepOrange,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.deepOrange,
                  ),
                  hintText: "Search",
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    //setIndex(0);
                    newDefault('pending');
                    //print(sdefault);
                  },
                  child: Container(
                      height: 39,
                      width: MediaQuery.of(context).size.width * 0.45,
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    //setIndex(1);
                    newDefault('complete');
                    //print(sdefault);
                  },
                  child: Container(
                      height: 39,
                      width: MediaQuery.of(context).size.width * 0.45,
                      color: Colors.deepOrange,
                      child: Center(
                        child: Text(
                          'Fullfilled',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: sdefault.toString() == 'pending'
                  ? TransactionList(tstatus: sdefault.toString())
                  : TransactionList(tstatus: cdefault.toString()),
            )
          ])),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Merchant name'),
        backgroundColor: XploreColors.deepBlue,
        automaticallyImplyLeading: true,
        bottom: XploreAppBar(),
      ),
      body: tabs[currentIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.grey[100],
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 50,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setBottomBarIndex(0);
                },
                child: Container(
                    height: 39,
                    decoration: BoxDecoration(
                        color: currentIndex == 0
                            ? Colors.deepOrange
                            : Colors.white,
                        border: Border.all(color: Colors.deepOrange)),
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Center(
                      child: Text(
                        'Inventory',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: currentIndex == 0
                              ? Colors.white
                              : Colors.deepOrange,
                        ),
                      ),
                    )),
              ),

              InkWell(
                onTap: () {
                  setBottomBarIndex(1);
                },
                child: Container(
                    height: 39,
                    decoration: BoxDecoration(
                        color: currentIndex == 1
                            ? Colors.deepOrange
                            : Colors.white,
                        border: Border.all(color: Colors.deepOrange)),
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Center(
                      child: Text(
                        'Transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: currentIndex == 1
                              ? Colors.white
                              : Colors.deepOrange,
                        ),
                      ),
                    )),
              ),

              //       // button 1
              //   ConstrainedBox(
              //   constraints: BoxConstraints.tightFor(
              //       width: MediaQuery.of(context).size.width * 0.4,
              //       height: 40
              //   ),
              //   child: ElevatedButton(
              //         clipBehavior: Clip.none,
              //         child: Text('Inventory'),
              //         onPressed: (){
              //           setBottomBarIndex(0);
              //         },
              //         style: ButtonStyle(
              //             backgroundColor: MaterialStateProperty.all(currentIndex == 0 ? Colors.deepOrange : Colors.deepOrangeAccent[100],),
              //             //padding: MaterialStateProperty.all(EdgeInsets.all(50)),
              //             textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20, color: currentIndex == 0 ? Colors.white : Colors.deepOrange,))
              //           ),
              //       ),
              //   ),

              //       // button 2

              // ConstrainedBox(
              //   constraints: BoxConstraints.tightFor(
              //       width: MediaQuery.of(context).size.width * 0.4,
              //       height: 40
              //   ),
              //   child:ElevatedButton(
              //         clipBehavior: Clip.hardEdge,
              //         child: Text('Transactions'),
              //         onPressed: (){
              //           setBottomBarIndex(1);
              //         },
              //         style: ButtonStyle(
              //             backgroundColor: MaterialStateProperty.all(currentIndex == 1 ? Colors.deepOrange : Colors.deepOrangeAccent[100],),
              //             //padding: MaterialStateProperty.all(EdgeInsets.all(50)),
              //             textStyle: MaterialStateProperty.all(TextStyle(fontSize: 20, color: currentIndex == 1 ? Colors.white : Colors.deepOrange,))
              //         ),
              //       ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
