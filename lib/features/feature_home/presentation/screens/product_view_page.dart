import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:shamiri/features/feature_home/presentation/components/product_view/product_variations_view.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/controller/merchant_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  late final CarouselController _carouselController;
  late final FToast _toast;
  int itemCount = 1;

  @override
  void initState() {
    super.initState();

    _homeController = Get.find<HomeController>();
    _authController = Get.find<AuthController>();
    _merchantController = Get.find<MerchantController>();
    _carouselController = CarouselController();

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
            uid: _authController.user.value!.userId!,
            response: (state, error) {});
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
            uid: _authController.user.value!.userId!,
            response: (state, error) {});
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
    return Obx(
      () {
        final liveProduct = _merchantController.merchantProducts
            .firstWhere((prod) => prod.productId! == widget.product.productId!);

        final totalPrice = liveProduct.productSellingPrice == null
            ? _homeController.getTotalFromProductVariations(
                variations: _homeController.pickedVariations)
            : liveProduct.productSellingPrice!;

        // final isInCart = _authController
        //     .user.value!.itemsInCart!
        //     .map((item) => item.cartProductId)
        //     .toList()
        //     .contains(liveProduct.productId!);

        return Scaffold(
          backgroundColor: XploreColors.white,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: XploreColors.white,
                systemNavigationBarColor: XploreColors.white,
                systemNavigationBarIconBrightness: Brightness.dark),
            backgroundColor: XploreColors.white,
            leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_rounded,
                    color: XploreColors.deepBlue)),
            actions: [
              IconButton(
                  onPressed: () => Get.to(() => CartScreen()),
                  icon: Obx(
                    () => BadgeIcon(
                        badgeCount:
                            _authController.user.value!.itemsInCart!.length,
                        iconData: Icons.shopping_cart_rounded),
                  )),
              //  edit icon
              Visibility(
                visible: _merchantController.merchantProducts
                    .map((product) => product.productId!)
                    .contains(liveProduct.productId!),
                child: IconButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        openBottomSheet(
                            content: Obx(
                              () => AddProductBottomSheet(
                                product: _merchantController.merchantProducts
                                    .firstWhere((product) =>
                                        product.productId! ==
                                        liveProduct.productId!),
                              ),
                            ),
                            onComplete: () {});
                      });
                    },
                    icon:
                        Icon(Icons.edit_rounded, color: XploreColors.deepBlue)),
              ),

              //  delete icon
              Visibility(
                visible: _merchantController.merchantProducts
                    .map((product) => product.productId!)
                    .contains(liveProduct.productId!),
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
                                productId: liveProduct.productId!);
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
              liveProduct.productImageUrls != null &&
                      liveProduct.productImageUrls!.isNotEmpty
                  ? Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: CarouselSlider.builder(
                          itemCount: liveProduct.productImageUrls!.length,
                          itemBuilder: (context, index, realIndex) {
                            final currentImageUrl =
                                liveProduct.productImageUrls![index];

                            return CachedNetworkImage(
                                imageUrl: currentImageUrl,
                                placeholder: (context, url) => Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 350,
                                    color: XploreColors.deepBlue,
                                    child: Icon(
                                      Icons.category_rounded,
                                      color: XploreColors.white,
                                      size: 72,
                                    )),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover);
                          },
                          carouselController: _carouselController,
                          options: CarouselOptions(
                              height: 300,
                              initialPage: 0,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: false,
                              viewportFraction: 1,
                              scrollPhysics: const BouncingScrollPhysics(),
                              onPageChanged: (index, reason) {
                                _homeController
                                    .setActiveProductImageIndex(index);
                              })),
                    )
                  : Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: UnconstrainedBox(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 350,
                              color: XploreColors.deepBlue,
                              child: Icon(
                                Icons.category_rounded,
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
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: AnimatedSmoothIndicator(
                            activeIndex:
                                _homeController.activeProductImageIndex.value,
                            count: liveProduct.productImageUrls!.length,
                            effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: XploreColors.xploreOrange,
                                dotColor:
                                    XploreColors.deepBlue.withOpacity(0.2)),
                            onDotClicked: (index) {
                              _carouselController.animateToPage(index);
                            },
                          ),
                        ),

                        //  product name
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //  product name
                              Text(
                                liveProduct.productName!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              vSize10SizedBox,
                              //  product price
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    liveProduct.productSellingPrice == null
                                        ? 'Priced by variants'
                                        : 'Ksh. ${liveProduct.productSellingPrice!.toString().addCommas}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: XploreColors.deepBlue),
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: liveProduct.productStockCount!
                                              .toString()
                                              .addCommas,
                                          style: TextStyle(
                                              color: XploreColors.white,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: ' units remaining.',
                                          style: TextStyle(
                                              color: XploreColors.white)),
                                    ])),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        vSize30SizedBox,

                        //  product units left
                        Text.rich(TextSpan(children: [
                          TextSpan(text: 'Unit: ', style: TextStyle()),
                          TextSpan(
                              text:
                                  liveProduct.productUnit!.toString().addCommas,
                              style: TextStyle(
                                  color: XploreColors.xploreOrange,
                                  fontWeight: FontWeight.bold)),
                        ])),

                        vSize30SizedBox,

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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),

                            vSize20SizedBox,

                            //  description
                            Text(
                              liveProduct.productDescription!.isEmpty
                                  ? "No description"
                                  : liveProduct.productDescription!,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ],
                        ),

                        //  product variations
                        Visibility(
                            visible: liveProduct.productVariations!.isNotEmpty,
                            child: Column(
                              children: [
                                vSize30SizedBox,
                                ProductVariationsView(product: liveProduct),
                              ],
                            )),

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
                    .contains(liveProduct.productId!),
                child: Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: liveProduct.productStockCount! < 1
                        ? Container(
                            height: 50,
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
                        : Container(
                            width: MediaQuery.of(context).size.width - 16,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                                color: XploreColors.orange,
                                borderRadius: BorderRadius.circular(8)),
                            child: Container(
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
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(100),
                                                  bottomLeft:
                                                      Radius.circular(100))),
                                          child: Text.rich(TextSpan(children: [
                                            TextSpan(
                                                text: 'Total : ',
                                                style: TextStyle(
                                                    color: XploreColors
                                                        .whiteSmoke)),
                                            TextSpan(
                                                text:
                                                    "Ksh. ${totalPrice.toString().addCommas}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: XploreColors.white,
                                                    fontWeight: FontWeight.w700,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          ])))),
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(100),
                                                bottomRight:
                                                    Radius.circular(100))),
                                        child: GestureDetector(
                                          onTap: () async {
                                            //  get initial cart items
                                            List<CartModel> itemsInCart =
                                                _authController
                                                    .user.value!.itemsInCart!;
                                            //  Add item to list
                                            itemsInCart = itemsInCart
                                              ..add(CartModel(
                                                  cartProductId:
                                                      liveProduct.productId!,
                                                  cartProductCount: itemCount,
                                                  cartProductTotal:
                                                      totalPrice));
                                            //  update items in cart
                                            await _authController
                                                .updateUserDataInFirestore(
                                                    oldUser: _authController
                                                        .user.value!,
                                                    newUser: UserModel(
                                                        itemsInCart:
                                                            itemsInCart),
                                                    uid: _authController
                                                        .user.value!.userId!,
                                                    response:
                                                        (state, error) {});

                                            //  show toast
                                            showToast(
                                                toast: _toast,
                                                iconData: Icons
                                                    .add_shopping_cart_rounded,
                                                msg:
                                                    'Product added to cart successfully');
                                            //  clear selected variations
                                            _homeController
                                                .clearPickedVariations();
                                          },
                                          child: UnconstrainedBox(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      XploreColors.xploreOrange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .add_shopping_cart_rounded,
                                                      color:
                                                          XploreColors.white),
                                                  hSize10SizedBox,
                                                  Text(
                                                    "Add to cart",
                                                    style: TextStyle(
                                                        color:
                                                            XploreColors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                          )),
              )
            ],
          ),
        );
      },
    );
  }
}
