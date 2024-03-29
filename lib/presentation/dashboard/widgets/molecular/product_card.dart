// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:shamiri/application/core/services/helpers.dart';
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/domain/models/categories/category.dart';
import 'package:shamiri/domain/models/products/product.dart';
import 'package:shamiri/domain/models/transactions/order.dart';
import 'package:shamiri/domain/value_objects/app_enums.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/domain/value_objects/app_strings.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // ProductRepository productRepositoryInstance = ProductRepository();
  // TransactionRepository transactionRepositoryInstance = TransactionRepository();

  @override
  Widget build(BuildContext context) {
    final String prodName = widget.product.name.toString();
    final String prodQtyInStock = widget.product.quantityInStock.toString();
    final String quantityOrdered = widget.product.quantityOrdered.toString();
    final String prodSp = widget.product.sellingPrice.toString();
    final String prodBp = widget.product.buyingPrice.toString();
    final String productUnit = widget.product.metricUnit!.toString();
    final String prodImag = widget.product.imageList!.first.toString();
    final String productRef = widget.product.productRefID.toString();
    final String businessUID = widget.product.businessUID.toString();
    final String category = '';

    final int rem = int.parse(prodQtyInStock) - 1;
    final Product newProduct = Product(
      name: prodName,
      quantityInStock: rem.toString(),
      sellingPrice: prodSp,
      buyingPrice: prodBp,
      imageList: [prodImag],
      productRefID: productRef,
      businessUID: businessUID,
      quantityOrdered: '1',
      metricUnit: productUnit,
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: XploreColors.xploreOrange.withOpacity(.3),
            child: AspectRatio(
              aspectRatio: 22.0 / 12.0,
              child: InkWell(
                  child: Icon(
                    Icons.inventory,
                    color: XploreColors.deepBlueAccent,
                  ),
                  onTap: () {
                    // Navigator.pushNamed(
                    //   context,
                    //   arguments: Product(
                    //     name: prodName,
                    //     quantityInStock: prodQtyInStock,
                    //     quantityOrdered: quantityOrdered,
                    //     sellingPrice: prodSp,
                    //     buyingPrice: prodBp,
                    //     metricUnit: productUnit,
                    //     categories: [Category(name: category)],
                    //     imageList: [prodImag],
                    //     productRefID: productRef,
                    //   ),
                    // );
                  }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('$prodName',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('$prodQtyInStock Left',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('$prodSp KES',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  InkWell(
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: XploreColors.xploreOrange,
                      ),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Order',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                            hSize10SizedBox,
                            Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 21,
                              color: XploreColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      var now = DateTime.now();
                      final format = DateFormat('yyyy-MM-dd HH:mm');
                      var date = format.format(now);

                      var newOrder = Order(
                        businessUID: businessUID,
                        status: TransactionStatus.pending,
                        products: [newProduct.productRefID ?? ''],
                        date: date,
                      );

                      // productRepositoryInstance.updateProduct(newProduct);
                      // _addNewTransaction(newOrder).whenComplete(() {
                      //   setState(() {
                      //     ScaffoldMessenger.of(context)
                      //       ..hideCurrentSnackBar()
                      //       ..showSnackBar(
                      //         SnackBar(
                      //           content: Text(orderAdded),
                      //           duration: const Duration(
                      //               seconds: kShortSnackBarDuration),
                      //           action: dismissSnackBar(
                      //               okText, XploreColors.white, context),
                      //         ),
                      //       );
                      //   });
                      // });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _addNewTransaction(Order newOrder) async {
  //   await transactionRepositoryInstance
  //       .recordOrder(newOrder)
  //       .then((newOrderRef) {
  //     transactionRepositoryInstance.updateOrderRef(newOrderRef.id);
  //   });
  // }
}
