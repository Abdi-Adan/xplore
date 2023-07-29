import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamiri/application/core/themes/colors.dart';
import 'package:shamiri/core/presentation/components/hamburger.dart';
import 'package:shamiri/domain/value_objects/app_spaces.dart';
import 'package:shamiri/features/feature_home/presentation/components/all_products_section.dart';
import 'package:shamiri/features/feature_home/presentation/components/top_stores_section.dart';

import '../../../core/presentation/components/custom_textfield.dart';
import 'components/pill_btn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XploreColors.white,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  //  Search bar
                  SliverToBoxAdapter(
                    child: CustomTextField(
                        hint: "Search For Products",
                        iconData: Icons.search_rounded,
                        textStyle: TextStyle(fontSize: 16),
                        controller: _searchController,
                        onChanged: (value) {}),
                  ),

                  SliverToBoxAdapter(child: vSize30SizedBox),

                  //  top stores section
                  TopStoresSection(),

                  SliverToBoxAdapter(child: vSize30SizedBox),

                  SliverToBoxAdapter(
                    child: //  all products pill buttons
                        Container(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: 10,
                              itemBuilder: (context, index) => index == 0
                                  ? PillBtn(
                                      text: "All",
                                      isActive: true,
                                      onTap: () {},
                                    )
                                  : PillBtn(text: "All", onTap: () {}),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
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
