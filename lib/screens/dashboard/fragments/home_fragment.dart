import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/components/banner_ads_widget.dart';
import 'package:news_flutter/components/see_all_button_widget.dart';
import 'package:news_flutter/model/category_model.dart';
import 'package:news_flutter/model/dashboard_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/category/category_list_screen.dart';
import 'package:news_flutter/screens/category/category_news_list_screen.dart';
import 'package:news_flutter/screens/dashboard/components/featured_news_home_widget.dart';
import 'package:news_flutter/screens/dashboard/components/greeting_widget.dart';
import 'package:news_flutter/screens/dashboard/components/news_list_view_widget.dart';
import 'package:news_flutter/screens/dashboard/components/news_sliding_widget.dart';
import 'package:news_flutter/screens/dashboard/short_news_screen_two.dart';
import 'package:news_flutter/screens/news/latest_news_list_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

class HomeFragment extends StatefulWidget {
  @override
  HomeFragmentState createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment> with TickerProviderStateMixin {
  int page = 1;

  bool showNoData = false;
  bool isLoadingSwipeToRefresh = false;
  bool isDashboardDataLoaded = false;

  DateTime? currentBackPressTime;

  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    appStore.setToScrolling(true);

    appStore.setLoading(true);

    _controller.addListener(() {
      /// scroll down
      if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
        appStore.setToScrolling(false);
      }

      /// scroll up
      if (_controller.position.userScrollDirection == ScrollDirection.forward) {
        appStore.setToScrolling(true);
      }
    });

    appStore.setLoading(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast('Press back again to exit app.');
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await 2.seconds.delay;
          setState(() {});
        },
        child: Scaffold(
          body: FutureBuilder<DashboardModel>(
            initialData: getStringAsync(dashboardData).isNotEmpty ? DashboardModel.fromJson(jsonDecode(getStringAsync(dashboardData))) : null,
            future: getDashboardApi(page),
            builder: (context, snap) {
              if (snap.hasData) {
                return SingleChildScrollView(
                  controller: _controller,
                  padding: EdgeInsets.only(top: context.statusBarHeight + 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add your sticky image here
                      GestureDetector(
                        onTap: () {
                          // Open URL when the image is clicked
                          String url = "https://tdpelmedia.com/tmads";
                          launch(url);
                        },
                        child: Image.network(
                          'https://app.tdpelmedia.com/advert.jpg',
                          fit: BoxFit.cover,
                          height: 100,
                          width: double.infinity,
                        ),
                      ),


                      GreetingWidget().paddingOnly(left: 16, top: 16, bottom: 8),

                      /// News Ticker
                      if (snap.data!.featurePost.validate().isNotEmpty) ...[
                        SizedBox(
                          height: 36,
                          child: NewsSlidingWidget(
                              key: UniqueKey(),
                              text: parseHtmlString(snap.data!.featureNewsMarquee),
                              style: boldTextStyle(size: textSizeLargeMedium, weight: FontWeight.w700),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: context.width() * 0.8,
                              velocity: 50,
                              pauseAfterRound: const Duration(seconds: 1),
                              showFadingOnlyWhenScrolling: true,
                              fadingEdgeStartFraction: 0.1,
                              fadingEdgeEndFraction: 0.1,
                              numberOfRounds: 10,
                              startPadding: 20,
                              accelerationDuration: const Duration(seconds: 1),
                              decelerationDuration: const Duration(milliseconds: 500)),
                        ),
                        8.height,
                        Divider(),
                      ],
                      if (snap.data!.featurePost.validate().isNotEmpty) FeaturedNewsHomeWidget(recentNewsListing: snap.data!.featurePost.validate()),
                      16.height,
                      FutureBuilder<List<CategoryModel>>(
                        initialData: getStringAsync(categoryData).isNotEmpty ? jsonDecode(getStringAsync(categoryData)).map<CategoryModel>((e) => CategoryModel.fromJson(e)).toList() : null,
                        future: getCategories(page: page, perPage: 5),
                        builder: (context, snap) {
                          if (snap.hasData) {
                            List<CategoryModel> categoryItems = snap.hasData ? snap.data! : jsonDecode(getStringAsync(categoryData)).map<CategoryModel>((e) => CategoryModel.fromJson(e)).toList();
                            if (categoryItems.validate().isNotEmpty) {
                              setValue(categoryData, jsonEncode(categoryItems));
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(language.categories, style: boldTextStyle(size: textSizeMedium)).expand(),
                                      SeeAllButtonWidget(
                                        onTap: () => CategoryListScreen(isTab: false).launch(context),
                                        widget: Text(language.seeAll, style: primaryTextStyle(color: primaryColor, size: textSizeSMedium)),
                                      ),
                                    ],
                                  ).paddingSymmetric(horizontal: 16),
                                  SingleChildScrollView(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    scrollDirection: Axis.horizontal,
                                    child: AnimatedWrap(
                                      listAnimationType: ListAnimationType.FadeIn,
                                      fadeInConfiguration: FadeInConfiguration(delay: 250.milliseconds, curve: Curves.easeOutQuad),
                                      itemCount: categoryItems.take(5).length,
                                      itemBuilder: (context, index) {
                                        CategoryModel data = categoryItems[index];
                                        return GestureDetector(
                                          onTap: () {
                                            CategoryNewsListScreen(title: data.name, id: data.cat_ID, categoryModel: data).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                                          },
                                          child: Container(
                                            height: 100,
                                            width: 160,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: context.cardColor),
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            child: Stack(
                                              children: [
                                                Hero(
                                                  tag: data,
                                                  child: cachedImage(data.image.validate(), height: 100, width: 160, fit: BoxFit.cover),
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
                                                    parseHtmlString(data.name.validate()),
                                                    style: boldTextStyle(size: textSizeMedium, color: Colors.black),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ).paddingAll(8),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ).paddingAll(4);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return SizedBox();
                            }
                          }
                          return SizedBox();
                        },
                      ),
                      16.height,
                      if (!isAdsDisabled && snap.data!.banner.validate().isNotEmpty) ...[
                        BannerAdsWidget(bannerData: snap.data!.banner.validate()),
                        16.height,
                      ],
                      if (snap.data!.recentPost.validate().isNotEmpty)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  language.latestNews,
                                  style: boldTextStyle(size: textSizeMedium),
                                ),
                              ],
                            ).paddingSymmetric(horizontal: 16),
                            NewsListViewWidget(latestNewsList: snap.data!.recentPost.validate()),
                            Center(
                              child: SeeAllButtonWidget(
                                onTap: () {
                                  LatestNewsListScreen(
                                    title: language.latestNews,
                                    newsType: NewsListType.LATEST_NEWS,
                                  ).launch(context);
                                },
                                widget: Text(
                                  language.seeAll,
                                  style: primaryTextStyle(color: primaryColor, size: textSizeSMedium),
                                ),
                              ),
                            ),
                          ],
                        ),

                    ],
                  ),
                );
              }


              if (snap.hasError) {
                return NoDataWidget(title: language.somethingWentWrong, image: ic_no_data);
              }
              return Loader(color: primaryColor, valueColor: AlwaysStoppedAnimation(Colors.white)).center();
            },
          ),

        ),
      ),
    );
  }
}
