import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/model/category_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/category/category_news_list_screen.dart';
import 'package:news_flutter/shimmerScreen/category_shimmer.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';

class CategoryListScreen extends StatefulWidget {
  final bool? isTab;

  CategoryListScreen({this.isTab});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> with TickerProviderStateMixin {
  List<CategoryModel> categoryList = [];
  var scrollController = ScrollController();

  bool isLastPage = false;

  int page = 1;

  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    myBanner = buildBannerAd()..load();
    init();
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
    fetchCategoryData(page: 1, perPageItem: perPageItemInCategory);
    scrollController.addListener(() {
      if (!isLastPage && (scrollController.position.pixels - 100 == scrollController.position.maxScrollExtent - 100)) {
        page++;
        appStore.setLoading(true);
        setState(() {});
        fetchCategoryData(page: page);
      }
    });
  }

  Future<void> init() async {
    if (allowPreFetched) {
      String res = getStringAsync(categoryData);
      if (res.isNotEmpty) {
        var categoryList = json.decode(res) as List<dynamic>;
        var list = categoryList.map((i) => CategoryModel.fromJson(i)).toList();

        setData(list);
      }
    }

    if (await isNetworkAvailable()) {
      fetchCategoryData(page: 1, perPageItem: perPageItemInCategory);
    }
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: BANNER_AD_ID_FOR_ANDROID,
      size: AdSize.banner,
      listener: BannerAdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(),
    );
  }

  Future<void> fetchCategoryData({int page = 1, int perPageItem = perPageItemInCategory}) async {
    await getCategories(page: page, perPage: perPageItem).then((res) async {
      if (!mounted) return;
      appStore.setLoading(false);

      if (page == 1) {
        categoryList.clear();
      }

      setData(res);
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);

      toast(error.toString());
      setState(() {});
    });
  }

  void setData(List<CategoryModel> res) {
    isLastPage = res.length != perPageCategory;
    categoryList.addAll(res);
    afterBuildCreated(() {
      appStore.setLoading(false);
    });
    setState(() {});
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.categories,
        center: true,
        color: appStore.isDarkMode ? appBackGroundColor : white,
        elevation: 0.2,
        showBack: !widget.isTab!,
        backWidget: BackWidget(color: context.iconColor),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              return await fetchCategoryData();
            },
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(bottom: 32),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: AnimatedWrap(
                  listAnimationType: ListAnimationType.Scale,
                  scaleConfiguration: ScaleConfiguration(delay: 100.milliseconds, curve: Curves.easeOutQuad),
                  spacing: 8,
                  runSpacing: 8,
                  itemCount: categoryList.length,
                  itemBuilder: (ctx, index) {
                    CategoryModel category = categoryList[index];

                    return GestureDetector(
                      onTap: () {
                        CategoryNewsListScreen(title: category.name, id: category.cat_ID, categoryModel: category).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                      child: Container(
                        height: 150,
                        width: (context.width() / 2) - 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          color: context.cardColor,
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Stack(
                          children: [
                            Hero(
                              tag: category,
                              child: Image.network(
                                category.image.validate(),
                                height: 150,
                                width: (context.width() / 2) - 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage('https://i.ibb.co/7GmNG4F/tdpel.png'), // Replace with the path to your image
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Text(
                                parseHtmlString(category.name.validate()),
                                style: boldTextStyle(size: textSizeLargeMedium, color: Colors.black),
                              ).paddingAll(8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Observer(builder: (context) => NoDataWidget(title: language.noRecordFound, image: ic_no_data).center().visible(!appStore.isLoading && categoryList.isEmpty)),
          50.height,
          Observer(
            builder: (context) {
              return Align(alignment: Alignment.bottomCenter, child: Loader(color: primaryColor, valueColor: AlwaysStoppedAnimation(Colors.white)).visible(appStore.isLoading && page != 1));
            },
          ),
          Observer(builder: (_) => CategoryShimmer().visible(appStore.isLoading && categoryList.isEmpty)),
        ],
      ),
      bottomNavigationBar: !isAdsDisabled && !widget.isTab!
          ? Container(
              height: AdSize.banner.height.toDouble(),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: myBanner != null ? AdWidget(ad: myBanner!) : SizedBox(),
            )
          : SizedBox(),
    );
  }
}
