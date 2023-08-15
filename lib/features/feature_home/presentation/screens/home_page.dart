import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/core/utils/constants.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/features/feature_home/presentation/components/all_products_section.dart';
import 'package:shamiri/features/feature_home/presentation/components/top_stores_section.dart';
import 'package:shamiri/features/feature_home/presentation/controller/home_controller.dart';
import 'package:shamiri/features/feature_search/presentation/search_screen.dart';

import '../../../../core/presentation/components/custom_textfield_alt.dart';
import '../../../../presentation/core/widgets/molecular/dashboard_tab_action_button.dart';
import '../components/pill_btn.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _searchController;
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();

    _homeController = Get.find<HomeController>();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XploreColors.white,
      floatingActionButton: CustomFAB(
          actionIcon: Icons.qr_code_scanner_rounded,
          actionLabel: "Scan QR code",
          onPressed: () {
            //  open bottomsheet to add products

          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  //  Search bar
                  SliverToBoxAdapter(
                    child: Material(
                      elevation: 4,
                      child: Container(
                        width: double.infinity,
                        color: XploreColors.white,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Hero(
                          tag: 'search',
                          child: GestureDetector(
                            onTap: () => Get.to(() => SearchPage(products: _homeController.products)),
                            child: CustomTextFieldAlt(
                                hint: "Search For Products",
                                iconData: Icons.search_rounded,
                                textStyle: TextStyle(fontSize: 16),
                                isEnabled: false,
                                controller: _searchController,
                                onChanged: (value) {}),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: vSize30SizedBox),

                  //  top stores section
                  TopStoresSection(),

                  SliverToBoxAdapter(child: vSize30SizedBox),

                  //  all products pill buttons
                  SliverToBoxAdapter(
                    child: Container(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: Constants.productCategories.length,
                          itemBuilder: (context, index) => Obx(
                            () => PillBtn(
                              text: Constants
                                  .productCategories[index].categoryName,
                              iconData: Constants
                                  .productCategories[index].categoryIcon,
                              isActive: _homeController.activeCategory.value ==
                                  Constants.productCategories[index],
                              onTap: () => _homeController.setActiveCategory(
                                  Constants.productCategories[index]),
                            ),
                          ),
                          separatorBuilder: (context, index) => const SizedBox(
                            width: 8,
                          ),
                        )),
                  ),

                  SliverToBoxAdapter(child: vSize30SizedBox),

                  //  all products toggle pill buttons
                  AllProductsSection()
                ],
              ))),
    );
  }
}
