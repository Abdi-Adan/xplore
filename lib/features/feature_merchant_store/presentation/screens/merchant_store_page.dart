import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/core/presentation/components/my_lottie.dart';
import 'package:shamiri/features/feature_home/presentation/screens/product_view_page.dart';
import 'package:shamiri/features/feature_merchant_store/domain/model/product_model.dart';
import 'package:shamiri/core/presentation/components/open_bottom_sheet.dart';
import 'package:shamiri/core/presentation/components/product_card_alt.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/add_product_bottom_sheet.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/product_actions_bottom_sheet.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/components/store_overview_card.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/controller/merchant_controller.dart';
import 'package:shamiri/features/feature_merchant_store/presentation/screens/merchant_transactions.dart';
import 'package:shamiri/presentation/core/widgets/molecular/dashboard_tab_action_button.dart';
import 'package:get/get.dart';

import '../../../../core/presentation/components/custom_textfield_alt.dart';
import '../../../../core/presentation/controller/auth_controller.dart';
import '../../../../core/utils/constants.dart';
import '../../../feature_home/presentation/components/pill_btn.dart';
import '../../../feature_search/presentation/search_screen.dart';

class MerchantStorePage extends StatefulWidget {
  const MerchantStorePage({super.key});

  @override
  State<MerchantStorePage> createState() => _MerchantStorePageState();
}

class _MerchantStorePageState extends State<MerchantStorePage> {
  late final MerchantController _merchantController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();

    _merchantController = Get.find<MerchantController>();
    _authController = Get.find<AuthController>();

    _merchantController.getMerchantProducts().listen((snapshot) {
      var products = snapshot.docs
          .map((product) =>
              ProductModel.fromJson(product.data() as Map<String, dynamic>))
          .toList();

      _merchantController.setProducts(products: products);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: XploreColors.white,
        floatingActionButton: CustomFAB(
            actionIcon: Icons.add_circle_rounded,
            actionLabel: "Add Products",
            onPressed: () {
              //  open bottomsheet to add products
              openBottomSheet(
                  content: AddProductBottomSheet(),
                  onComplete: () {
                    //  clear chosen variations
                    _merchantController.clearProductVariations();
                  });
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: vSize20SizedBox,
            ),
            //  store overview
            Obx(
              () => StoreOverviewCard(
                store: _authController.user.value!,
              ),
            ),

            SliverToBoxAdapter(
              child: vSize20SizedBox,
            ),

            //  store transactions
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    //  open transactions page
                    Get.to(() => MerchantTransactions());
                  },
                  child: Ink(
                    width: double.infinity,
                    height: 60,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: XploreColors.deepBlue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                color: XploreColors.white),
                            hSize20SizedBox,
                            Text("My Transactions",
                                style: TextStyle(color: XploreColors.white)),
                          ],
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: XploreColors.white)
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Obx(
                () => Visibility(
                    visible: _merchantController.merchantProducts.isNotEmpty,
                    child: vSize20SizedBox),
              ),
            ),

            //  my products header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                  child: Obx(
                () => Visibility(
                    visible: _merchantController.merchantProducts.isNotEmpty,
                    child: Text("My Products", style: TextStyle(fontSize: 18))),
              )),
            ),

            SliverToBoxAdapter(
              child: vSize20SizedBox,
            ),

            //  all products pill buttons
            SliverToBoxAdapter(
              child: Obx(
                () => Visibility(
                  visible: _merchantController.merchantProducts.isNotEmpty,
                  child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: Constants.productCategories.length,
                        itemBuilder: (context, index) => Obx(
                          () {
                            final filteredProducts = _merchantController
                                .merchantProducts
                                .where((product) =>
                                    product.productCategoryId ==
                                    Constants
                                        .productCategories[index].categoryName)
                                .toList();

                            return filteredProducts.isNotEmpty ||
                                    Constants.productCategories[index]
                                            .categoryName ==
                                        'All'
                                ? PillBtn(
                                    text: Constants
                                        .productCategories[index].categoryName,
                                    iconData: Constants
                                        .productCategories[index].categoryIcon,
                                    isActive: _merchantController
                                            .activeCategory.value ==
                                        Constants.productCategories[index],
                                    onTap: () =>
                                        _merchantController.setActiveCategory(
                                            Constants.productCategories[index]),
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                        separatorBuilder: (context, index) => const SizedBox(
                          width: 8,
                        ),
                      )),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: vSize20SizedBox,
            ),

            Obx(() {
              final filteredProducts =
                  _merchantController.activeCategory.value.categoryName == 'All'
                      ? _merchantController.merchantProducts
                      : _merchantController.merchantProducts
                          .where((product) =>
                              product.productCategoryId ==
                              _merchantController
                                  .activeCategory.value.categoryName)
                          .toList();

              return filteredProducts.isNotEmpty
                  ? SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductCardAlt(
                                    product: filteredProducts.elementAt(index),
                                    onTap: () {
                                      Get.to(() => ProductViewPage(
                                          product: filteredProducts
                                              .elementAt(index)));
                                    },
                                    onDelete: () async {
                                      //  delete product
                                      _merchantController.deleteProduct(
                                          productId: filteredProducts
                                              .elementAt(index)
                                              .productId!);
                                    },
                                  ),
                              childCount: filteredProducts.length)),
                    )
                  : SliverToBoxAdapter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyLottie(
                            lottie: 'assets/general/xplore_loader.json',
                            height: 150,
                          ),
                          vSize10SizedBox,
                          Text("No Products yet")
                        ],
                      ),
                    );
            }),

            SliverToBoxAdapter(child: SizedBox(height: 64))
          ],
        ));
  }
}
