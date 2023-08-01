import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/components/loading_dot_widget.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/news/components/news_detail_page_variant_first_widget.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';

// ignore: must_be_immutable
class NewsDetailScreen extends StatefulWidget {
  final String newsId;
  PostModel? post;

  NewsDetailScreen({required this.newsId, this.post});

  @override
  NewsDetailScreenState createState() => NewsDetailScreenState();
}

class NewsDetailScreenState extends State<NewsDetailScreen> {
  Future<PostModel>? future;

  int fontSize = 18;
  String postContent = '';

  @override
  void initState() {
    super.initState();
    init();
    buildInterstitialAd();
  }

  void init() async {
    future = getBlogDetail({'post_id': widget.newsId});
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  void buildInterstitialAd() {
    InterstitialAd.load(
      adUnitId: INTERSTITIAL_AD_ID_FOR_ANDROID,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) async {
          print('$ad loaded');
          await Future.delayed(Duration.zero);
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
        },
      ),
    );
  }

  Future<void> savePostResponse(PostModel res, int id) async {
    setValue('$newsDetailData${widget.newsId}', jsonEncode(res));
  }

  Widget getVariant({required PostModel postModel, required int id}) {
    savePostResponse(postModel, id);
    postContent = getPostContent(postModel.postContent);

    return NewsDetailPageVariantFirstWidget(post: postModel, postContent: postContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<PostModel>(
            initialData: widget.post,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return getVariant(postModel: snap.data!, id: snap.data!.iD.validate());
              } else if (snap.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language.somethingWentWrong, style: secondaryTextStyle()),
                    8.height,
                    AppButton(
                      text: language.clickToRefresh,
                      onTap: () {
                        appStore.setLoading(true);
                        init();

                        setState(() {});

                        2.seconds.delay.then((value) => appStore.setLoading(false));
                      },
                      color: primaryColor,
                      textStyle: boldTextStyle(color: Colors.white),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ],
                ).center();
              }
              return LoadingDotsWidget().center();
            },
          ),
          Observer(builder: (context) => LoadingDotsWidget().center(heightFactor: 20).visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
