import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/core/domain/model/cart_model.dart';
import 'package:shamiri/core/domain/model/user_model.dart';
import 'package:shamiri/core/presentation/components/show_alert_dialog.dart';
import 'package:shamiri/core/presentation/components/show_toast.dart';
import 'package:shamiri/core/presentation/controller/auth_controller.dart';
import 'package:shamiri/core/utils/extensions/string_extensions.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/controller/merchant_controller.dart';

import '../../../../core/presentation/components/badged_icon.dart';
import '../../../../core/presentation/components/open_bottom_sheet.dart';
import '../../../feature_cart/presentation/screens/cart_screen.dart';
import '../../../feature_merchant_store/domain/model/product_model.dart';
import '../../../feature_merchant_store/presentation/components/add_product_bottom_sheet.dart';
import '../controller/home_controller.dart';

class ProductViewPage extends StatefulWidget {
  final ProductModel product;

  const ProductViewPage({super.key, required this.product});

  @override
  State<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  late final HomeController _homeController;
  late final AuthController _authController;
  late final MerchantController _merchantController;
  late final FToast _toast;
  int itemCount = 1;

  @override
  void initState() {
    super.initState();

    _homeController = Get.find<HomeController>();
    _authController = Get.find<AuthController>();
    _merchantController = Get.find<MerchantController>();

    _toast = FToast();
    _toast.init(context);
  }

  void decrementCount({required bool isInCart}) {
    if (isInCart) {
      var cartItem = _authController.user.value!.itemsInCart!.firstWhere(
          (item) => item.cartProductId == widget.product.productId!);

      var currentCartCount = cartItem.cartProductCount!;

      if (currentCartCount > 1) {
        currentCartCount -= 1;
        itemCount -= 1;

        _authController
            .user
            .value!
            .itemsInCart![_authController.user.value!.itemsInCart!.indexWhere(
                (item) => item.cartProductId! == widget.product.productId!)]
            .cartProductCount = currentCartCount;

        //  update items in cart
        _authController.updateUserDataInFirestore(
            oldUser: _authController.user.value!,
            newUser: UserModel(
                itemsInCart: _authController.user.value!.itemsInCart!),
            uid: _authController.user.value!.userId!);
      } else {
        showToast(
            toast: _toast,
            iconData: Icons.store_rounded,
            msg: "Cannot add 0 items to cart");
      }
    } else {
      setState(() {
        if (itemCount > 1) {
          itemCount -= 1;
        } else {
          showToast(
              toast: _toast,
              iconData: Icons.store_rounded,
              msg: "Cannot add 0 items to cart");
        }
      });
    }
  }

  void incrementCount({required bool isInCart}) {
    if (isInCart) {
      var cartItem = _authController.user.value!.itemsInCart!.firstWhere(
          (item) => item.cartProductId == widget.product.productId!);

      var currentCartCount = cartItem.cartProductCount!;

      if (currentCartCount < widget.product.productStockCount!) {
        currentCartCount += 1;
        itemCount += 1;

        _authController
            .user
            .value!
            .itemsInCart![_authController.user.value!.itemsInCart!.indexWhere(
                (item) => item.cartProductId! == widget.product.productId!)]
            .cartProductCount = currentCartCount;

        //  update items in cart
        _authController.updateUserDataInFirestore(
            oldUser: _authController.user.value!,
            newUser: UserModel(
                itemsInCart: _authController.user.value!.itemsInCart!),
            uid: _authController.user.value!.userId!);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showToast(
              toast: _toast,
              iconData: Icons.store_rounded,
              msg: "Reached max products in store");
        });
      }
    } else {
      setState(() {
        if (itemCount < widget.product.productStockCount!) {
          itemCount += 1;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showToast(
                toast: _toast,
                iconData: Icons.store_rounded,
                msg: "Reached max products in store");
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XploreColors.whiteSmoke,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: XploreColors.white,
            systemNavigationBarColor: XploreColors.white,
            systemNavigationBarIconBrightness: Brightness.dark),
        backgroundColor: XploreColors.white,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_rounded, color: XploreColors.deepBlue)),
        actions: [
          IconButton(
              onPressed: () => Get.to(() => CartScreen()),
              icon: Obx(
                () => BadgeIcon(
                    badgeCount: _authController.user.value!.itemsInCart!.length,
                    iconData: Icons.shopping_cart_rounded),
              )),
          //  edit icon
          Visibility(
            visible: _merchantController.merchantProducts
                .map((product) => product.productId!)
                .contains(widget.product.productId!),
            child: IconButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    openBottomSheet(
                        content: AddProductBottomSheet(
                          product: widget.product,
                        ),
                        onComplete: () {});
                  });
                },
                icon: Icon(Icons.edit_rounded, color: XploreColors.deepBlue)),
          ),

          //  delete icon
          Visibility(
            visible: _merchantController.merchantProducts
                .map((product) => product.productId!)
                .contains(widget.product.productId!),
            child: IconButton(
                onPressed: () async {
                  showAlertDialog(
                      title: "Delete Product",
                      iconData: Icons.delete_forever_rounded,
                      content: Text(
                        "Would you like to delete this product?",
                        textAlign: TextAlign.center,
                      ),
                      onCancel: () => Get.back(),
                      onConfirm: () async {
                        //  delete product
                        await _merchantController.deleteProduct(
                            productId: widget.product.productId!);
                        Get.back();
                        Get.back();
                      });
                },
                icon: Icon(Icons.delete_forever_rounded,
                    color: XploreColors.deepBlue)),
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          //  image
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: UnconstrainedBox(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    color: XploreColors.deepBlue,
                    child: widget.product.productImageUrl != null &&
                            widget.product.productImageUrl!.isNotEmpty
                        ? Image.network(
                            widget.product.productImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.shopping_cart_checkout_rounded,
                            color: XploreColors.white,
                            size: 72,
                          ))),
          ),

          //  content
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: UnconstrainedBox(
                child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: XploreColors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      topLeft: Radius.circular(5))),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  product name
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //  product name
                          Text(
                            widget.product.productName!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          vSize10SizedBox,
                          //  product price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Ksh. ${widget.product.productSellingPrice!.toString().addCommas}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Seller : ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: XploreColors.deepBlue),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.store_rounded,
                                          color: XploreColors.xploreOrange,
                                          size: 16,
                                        ),
                                        hSize10SizedBox,
                                        Obx(
                                          () => Text(
                                            _authController
                                                        .user.value!.userId! ==
                                                    widget.product.sellerId!
                                                ? 'My Store'
                                                : widget.product.sellerName!
                                                    .getStoreName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: XploreColors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    vSize20SizedBox,

                    //  product units left
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: widget.product.productStockCount!
                              .toString()
                              .addCommas,
                          style: TextStyle(
                              color: XploreColors.xploreOrange,
                              fontWeight: FontWeight.bold)),
                      TextSpan(text: ' units remaining.', style: TextStyle()),
                    ])),

                    vSize40SizedBox,

                    //  product description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              color: XploreColors.deepBlue,
                            ),
                            hSize10SizedBox,
                            Text(
                              "Description",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),

                        vSize20SizedBox,

                        //  description
                        Text(
                          widget.product.productDescription!.isEmpty
                              ? "No description"
                              : widget.product.productDescription!,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            )),
          ),

          //  add to cart button
          Visibility(
            visible: _merchantController.merchantProducts
                .map((product) => product.productId!)
                .contains(widget.product.productId!),
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: UnconstrainedBox(
                child: widget.product.productStockCount! < 1
                    ? Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: XploreColors.deepBlue,
                            borderRadius: BorderRadius.circular(100)),
                        child: Center(
                          child: Text(
                            "Product out of stock",
                            style: TextStyle(color: XploreColors.white),
                          ),
                        ),
                      )
                    : Obx(
                        () {
                          final isInCart = _authController
                              .user.value!.itemsInCart!
                              .map((item) => item.cartProductId)
                              .toList()
                              .contains(widget.product.productId!);

                          final totalPrice =
                              itemCount * widget.product.productSellingPrice!;

                          return Container(
                            width: isInCart ? 325 : 320,
                            height: 100,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: XploreColors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //  total price for products
                                Text.rich(TextSpan(children: [
                                  TextSpan(text: 'total : '),
                                  TextSpan(
                                      text:
                                          "Ksh. ${totalPrice.toString().addCommas}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                ])),

                                //  add to cart button and counter
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      color: XploreColors.deepBlue,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 5,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  100),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  100))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  //  minus icon
                                                  GestureDetector(
                                                    onTap: () => decrementCount(
                                                        isInCart: isInCart),
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: XploreColors
                                                                .white,
                                                            width: 4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: XploreColors
                                                            .deepBlue,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.remove_rounded,
                                                          color: XploreColors
                                                              .white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  //  counter
                                                  Expanded(
                                                    child: Center(
                                                      child: isInCart
                                                          ? Obx(() => Text(
                                                                _authController
                                                                    .user
                                                                    .value!
                                                                    .itemsInCart!
                                                                    .firstWhere((item) =>
                                                                        item.cartProductId ==
                                                                        widget
                                                                            .product
                                                                            .productId!)
                                                                    .cartProductCount
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: XploreColors
                                                                        .white,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ))
                                                          : Text(
                                                              itemCount
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      XploreColors
                                                                          .white,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                    ),
                                                  ),

                                                  //  Add Icon
                                                  GestureDetector(
                                                    onTap: () => incrementCount(
                                                        isInCart: isInCart),
                                                    child: Container(
                                                      width: 35,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: XploreColors
                                                                .white,
                                                            width: 4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: XploreColors
                                                            .deepBlue,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.add_rounded,
                                                          color: XploreColors
                                                              .white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ))),
                                      Expanded(
                                          flex: isInCart ? 7 : 5,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(100),
                                                    bottomRight:
                                                        Radius.circular(100))),
                                            child: GestureDetector(
                                              onTap: () async {
                                                //  get initial cart items
                                                List<CartModel> itemsInCart =
                                                    _authController.user.value!
                                                        .itemsInCart!;
                                                //  update the list
                                                if (isInCart) {
                                                  //  remove item from list
                                                  itemsInCart = itemsInCart
                                                    ..removeWhere((item) =>
                                                        item.cartProductId! ==
                                                        widget.product
                                                            .productId!);

                                                  //  update items in cart
                                                  await _authController
                                                      .updateUserDataInFirestore(
                                                          oldUser:
                                                              _authController
                                                                  .user.value!,
                                                          newUser: UserModel(
                                                              itemsInCart:
                                                                  itemsInCart),
                                                          uid: _authController
                                                              .user
                                                              .value!
                                                              .userId!);
                                                } else {
                                                  //  Add item to list
                                                  itemsInCart = itemsInCart
                                                    ..add(CartModel(
                                                        cartProductId: widget
                                                            .product.productId!,
                                                        cartProductCount:
                                                            itemCount));
                                                  //  update items in cart
                                                  await _authController
                                                      .updateUserDataInFirestore(
                                                          oldUser:
                                                              _authController
                                                                  .user.value!,
                                                          newUser: UserModel(
                                                              itemsInCart:
                                                                  itemsInCart),
                                                          uid: _authController
                                                              .user
                                                              .value!
                                                              .userId!);
                                                }
                                              },
                                              child: UnconstrainedBox(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: isInCart
                                                          ? XploreColors.red
                                                          : XploreColors
                                                              .xploreOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                          isInCart
                                                              ? Icons
                                                                  .remove_shopping_cart_rounded
                                                              : Icons
                                                                  .add_shopping_cart_rounded,
                                                          color: XploreColors
                                                              .white),
                                                      hSize10SizedBox,
                                                      Text(
                                                        isInCart
                                                            ? "Remove from cart"
                                                            : "Add to cart",
                                                        style: TextStyle(
                                                            color: XploreColors
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
