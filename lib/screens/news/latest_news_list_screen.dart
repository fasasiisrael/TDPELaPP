import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/news/news_detail_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/components/loading_dot_widget.dart';
import 'package:news_flutter/screens/news/components/news_item_widget.dart';
import 'package:news_flutter/shimmerScreen/news_item_shimmer.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';

import '../../main.dart';

class LatestNewsListScreen extends StatefulWidget {
  final String? title;
  final NewsListType newsType;

  LatestNewsListScreen({this.title, required this.newsType});

  @override
  LatestNewsListScreenState createState() => LatestNewsListScreenState();
}

class LatestNewsListScreenState extends State<LatestNewsListScreen> {
  ScrollController _scrollController = ScrollController();
  List<PostModel> recentNewsListing = [];

  int page = 1;
  int recentNumPages = 1;
  bool isLoading = false;
  bool isError = false;

  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    init();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (recentNumPages > page) {
          page++;
          fetchLatestData();
        }
      }
    });
  }

  init() async {
    myBanner = buildBannerAd()..load();

    fetchLatestData();
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: BANNER_AD_ID_FOR_ANDROID,
      size: AdSize.largeBanner,
      listener: BannerAdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(),
    );
  }

  Future<void> fetchLatestData() async {
    afterBuildCreated(() => appStore.setLoading(true));
    await getDashboardApi(page).then((value) async {
      if (page == 1) recentNewsListing.clear();
      if (widget.newsType == NewsListType.FEATURE_NEWS) {
        recentNumPages = value.featureNumPages.validate();
        recentNewsListing.addAll(value.featurePost.validate());
      } else {
        recentNumPages = value.recentNumPages.validate();
        recentNewsListing.addAll(value.recentPost.validate());
      }
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      log(e.toString());
    });
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    myBanner!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        parseHtmlString(widget.title),
        center: true,
        color: appStore.isDarkMode ? appBackGroundColor : white,
        elevation: 0.2,
        backWidget: BackWidget(color: context.iconColor),
      ),
      body: Observer(
        builder: (_) {
          return Stack(
            children: [

              AnimatedListView(
                slideConfiguration: SlideConfiguration(delay: 250.milliseconds, curve: Curves.easeOutQuad, verticalOffset: context.height() * 0.1),
                padding: EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 50),
                controller: _scrollController,
                itemCount: recentNewsListing.length,
                itemBuilder: (context, i) {
                  return NewsItemWidget(recentNewsListing[i], index: i).onTap(() {
                    NewsDetailScreen(post: recentNewsListing[i], newsId: recentNewsListing[i].toString()).launch(context);
                  });
                },
              ),

              NoDataWidget(title: isError ? language.somethingWentWrong : language.noRecordFound, image: ic_no_data).visible(!appStore.isLoading && recentNewsListing.validate().isEmpty),
              if (page == 1 && appStore.isLoading) NewsItemShimmer(),
              if (page > 1 && appStore.isLoading) Positioned(left: 0, right: 0, bottom: 16, child: LoadingDotsWidget())
            ],
          );
        },
      ),
    );
  }
}
