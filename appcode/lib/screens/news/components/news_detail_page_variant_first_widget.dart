import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/components/html_widget.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/screens/auth/sign_in_screen.dart';
import 'package:news_flutter/screens/comments/components/view_comment_widget.dart';
import 'package:news_flutter/screens/comments/write_comment_screen.dart';
import 'package:news_flutter/screens/news/components/comment_button_widget.dart';
import 'package:news_flutter/screens/news/components/post_media_widget.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../main.dart';

class NewsDetailPageVariantFirstWidget extends StatefulWidget {
  final PostModel? post;
  final String? postContent;


  NewsDetailPageVariantFirstWidget({this.post, this.postContent});

  @override
  NewsDetailPageVariantFirstWidgetState createState() => NewsDetailPageVariantFirstWidgetState();
}

class NewsDetailPageVariantFirstWidgetState extends State<NewsDetailPageVariantFirstWidget> {
  ScrollController _scrollController = ScrollController();
  bool isPostLoaded = false;
  String newsTitle = '';
  bool isBookMark = false;
  bool showAd = false;
  bool _isStickyBannerAdLoaded = false;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;



  int fontSize = 18;

  PostType postType = PostType.HTML;
  BannerAd? myBanner1;
  BannerAd? myBanner2;
  BannerAd? myBanner3;
  BannerAd? myBanner4;
  BannerAd? _stickyBanner;



  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'NewsDetailPageVariantFirstWidget');

    super.initState();
    afterBuildCreated(() {
      myBanner1 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_1)..load();
      myBanner2 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_2)..load();
      myBanner3 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_3)..load();
      myBanner4 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_4)..load();
      _stickyBanner = buildStickyBannerAd(YOUR_STICKY_AD_UNIT_ID);
      _stickyBanner?.load();
    });
  }

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
    String screenName = 'NewsDetailPageVariantFirstWidget';
    analytics.setCurrentScreen(screenName: screenName);
  }
  void launchEducationURL() async {
    const educationURL = 'https://tdpelmedia.com/category/education/';
    if (await canLaunch(educationURL)) {
      await launch(educationURL);
    } else {
      throw 'Could not launch $educationURL';
    }
  }

  void launchFashionURL() async {
    const fashionURL = 'https://tdpelmedia.com/category/fashion/';
    if (await canLaunch(fashionURL)) {
      await launch(fashionURL);
    } else {
      throw 'Could not launch $fashionURL';
    }
  }
  void launchEntertainmentURL() async {
    const entertainmentURL = 'https://tdpelmedia.com/category/entertainment/';
    if (await canLaunch(entertainmentURL)) {
      await launch(entertainmentURL);
    } else {
      throw 'Could not launch $entertainmentURL';
    }
  }

  void launchBreakingURL() async {
    const breakingURL = 'https://tdpelmedia.com/category/breaking-news/';
    if (await canLaunch(breakingURL)) {
      await launch(breakingURL);
    } else {
      throw 'Could not launch $breakingURL';
    }
  }

  void launchLifestyleURL() async {
    const lifestyleURL = 'https://tdpelmedia.com/category/lifestyle/';
    if (await canLaunch(lifestyleURL)) {
      await launch(lifestyleURL);
    } else {
      throw 'Could not launch $lifestyleURL';
    }
  }

  void launchHealthURL() async {
    const healthURL = 'https://tdpelmedia.com/category/health-news/';
    if (await canLaunch(healthURL)) {
      await launch(healthURL);
    } else {
      throw 'Could not launch $healthURL';
    }
  }

  void launchLotteryURL() async {
    const lotteryURL = 'https://tdpelmedia.com/category/lottery/';
    if (await canLaunch(lotteryURL)) {
      await launch(lotteryURL);
    } else {
      throw 'Could not launch $lotteryURL';
    }
  }

  void launchPeopleURL() async {
    const peopleURL = 'https://tdpelmedia.com/category/people/';
    if (await canLaunch(peopleURL)) {
      await launch(peopleURL);
    } else {
      throw 'Could not launch $peopleURL';
    }
  }

  void launchPoliticsURL() async {
    const politicsURL = 'https://tdpelmedia.com/category/allnews/';
    if (await canLaunch(politicsURL)) {
      await launch(politicsURL);
    } else {
      throw 'Could not launch $politicsURL';
    }
  }

  void launchReligionURL() async {
    const religionURL = 'https://tdpelmedia.com/category/religion/';
    if (await canLaunch(religionURL)) {
      await launch(religionURL);
    } else {
      throw 'Could not launch $religionURL';
    }
  }

  void launchScienceURL() async {
    const scienceURL = 'https://tdpelmedia.com/category/science/';
    if (await canLaunch(scienceURL)) {
      await launch(scienceURL);
    } else {
      throw 'Could not launch $scienceURL';
    }
  }

  void launchSportsURL() async {
    const sportsURL = 'https://tdpelmedia.com/category/sports/';
    if (await canLaunch(sportsURL)) {
      await launch(sportsURL);
    } else {
      throw 'Could not launch $sportsURL';
    }
  }

  void launchTechnologyURL() async {
    const technologyURL = 'https://tdpelmedia.com/category/technology/';
    if (await canLaunch(technologyURL)) {
      await launch(technologyURL);
    } else {

      throw 'Could not launch $technologyURL';
    }
  }

  void launchWeiredURL() async {
    const weiredURL = 'https://tdpelmedia.com/category/tdpeltv/';
    if (await canLaunch(weiredURL)) {
      await launch(weiredURL);
    } else {
      throw 'Could not launch $weiredURL';
    }
  }

  void launchWellnessURL() async {
    const wellnessURL = 'https://tdpelmedia.com/category/health/';
    if (await canLaunch(wellnessURL)) {
      await launch(wellnessURL);
    } else {
      throw 'Could not launch $wellnessURL';
    }
  }

  void launchWorldURL() async {
    const worldURL = 'https://tdpelmedia.com/category/news/';
    if (await canLaunch(worldURL)) {
      await launch(worldURL);
    } else {
      throw 'Could not launch $worldURL';
    }
  }

  void launchBusinessURL() async {
    const businessURL = 'https://tdpelmedia.com/category/business/';
    if (await canLaunch(businessURL)) {
      await launch(businessURL);
    } else {
      throw 'Could not launch $businessURL';
    }
  }




  Future<void> init() async {
    myBanner1 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_1)..load();
    myBanner2 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_2)..load();
    myBanner3 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_3)..load();
    myBanner4 = buildBannerAd(BANNER_AD_ID_FOR_ANDROID_4)..load();
  }


  @override
  void dispose() {
    myBanner1?.dispose();
    myBanner2?.dispose();
    myBanner3?.dispose();
    myBanner4?.dispose();
    _stickyBanner?.dispose();
    _scrollController.dispose();
    setStatusBarColor(
      appStore.isDarkMode ? card_color_dark : card_color_light,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
    super.dispose();
  }


  BannerAd buildBannerAd(String adUnitId) {
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Ad loaded callback
        },
        // Add other banner ad listener callbacks as needed
      ),
      request: AdRequest(),
    );
  }
  BannerAd buildStickyBannerAd(String adUnitId) {
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize(height: 50, width: AdSize.banner.width),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isStickyBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _stickyBanner?.dispose();
          _stickyBanner = null;
        },
        // Add other banner ad listener callbacks as needed
      ),
      request: AdRequest(),
    );
  }


  void onShareTap(String url) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share('$url?utm_source=TDPelApp&utm_medium=TDPelApp', subject: '', sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    String modifiedPostContent = widget.postContent?.replaceAll(RegExp(r'Advertisement'), '') ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBarWidget('',
          color: context.scaffoldBackgroundColor,
          showBack: true,
          elevation: 0,
          backWidget: Icon(Icons.arrow_back_ios, size: 20).onTap(() {
            finish(context);
          }),

          actions: [

            IconButton(
              icon: cachedImage(ic_send, width: 20, height: 20, color: primaryColor),
              onPressed: () {
                onShareTap(widget.post!.shareUrl.validate());
              },
            ),
            bookmarkStore.mBookmark.any((e) => e.iD == widget.post!.iD.validate())
                ? IconButton(
              icon: cachedImage(
                bookmarkStore.mBookmark.any((e) => e.iD == widget.post!.iD.validate()) ? ic_bookmarked : ic_bookmark,
                height: 20,
                width: 20,
                color: primaryColor,
              ),
              onPressed: () {
                if (appStore.isLoggedIn) {
                  bookmarkStore.addToWishList(widget.post!);
                } else {
                  SignInScreen().launch(context);
                }
                setState(() {});
              },
            )
                : IconButton(
              icon: cachedImage(
                bookmarkStore.mBookmark.any((e) => e.iD == widget.post!.iD.validate()) ? ic_bookmarked : ic_bookmark,
                height: 22,
                width: 22,
                color: primaryColor,
              ),
              onPressed: () {
                if (appStore.isLoggedIn) {
                  bookmarkStore.addToWishList(widget.post!);
                } else {
                  SignInScreen().launch(context);
                }
                setState(() {});
              },
            ),

          ]),
      body:
      Stack(

        children: [


          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 32, top: 8),
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clickable image widget
                GestureDetector(
                  onTap: () {
                    String url = "https://tdpelmedia.com/ads";
                    launch(url);
                  },
                  child: Image.network(
                    'https://app.tdpelmedia.com/advert.jpg',
                    fit: BoxFit.cover,
                    height: 100,
                    width: double.infinity,
                  ),
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.post!.category.validate().map((e) {
                    return Text(e.name.validate(), style: boldTextStyle(color: primaryColor));
                  }).toList(),
                ).paddingSymmetric(horizontal: 16),

                8.height,
                Text(
                  '${parseHtmlString(widget.post!.postTitle.validate())}',
                  style: boldTextStyle(
                    size: textSizeXLarge,
                  ),
                  maxLines: 5,
                ).paddingSymmetric(horizontal: 16),
                8.height,
                Row(
                  children: [
                    if (widget.post!.postAuthorName.validate().isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          authorImage(userImage: ic_profile),
                          6.width,
                          Text(
                            '${language.by + ' ${parseHtmlString(admin_author.any((e) => e == widget.post!.postAuthorName.validate()) ? APP_NAME : widget.post!.postAuthorName.validate())}'}',
                            style: primaryTextStyle(
                              // color: Theme.of(context)
                              //     .textTheme
                              //     .titleSmall!
                              //     .color,
                                fontStyle: FontStyle.italic),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).expand(),
                        ],
                      ).expand(),
                    Text(
                      widget.post!.readableDate.validate(),
                      style: secondaryTextStyle(
                        // color: Theme.of(context).textTheme.titleSmall!.color,
                          fontStyle: FontStyle.normal),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16),
                if (!isAdsDisabled && myBanner1 != null)
                  Container(
                    color: context.scaffoldBackgroundColor,
                    height: 250,
                    child: myBanner1 != null ? AdWidget(ad: myBanner1!) : SizedBox(),
                  ).paddingSymmetric(vertical: 16),
                16.height,
                widget.post!.postFormat.validate() == "video"
                    ? PostMediaWidget(widget.post!).paddingBottom(16)
                    : Hero(
                  tag: widget.post!,
                  child: cachedImage(
                    widget.post!.image.validate(),
                    height: 250,
                    width: context.width(),
                    fit: BoxFit.cover,
                  ),
                ),
                !isAdsDisabled && myBanner2 != null
                    ? Container(
                  color: context.scaffoldBackgroundColor,
                  height: 300,
                  child: myBanner2 != null ? AdWidget(ad: myBanner2!) : SizedBox(),
                ).paddingSymmetric(vertical: 16)
                    : SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Observer(
                      builder: (context) {
                        return HtmlWidget(
                          postContent: modifiedPostContent, // Use the modified postContent
                          fontSize: appStore.textFontSize,
                        ).paddingSymmetric(horizontal: 8);
                      },
                    ),
                    if (!isAdsDisabled && myBanner3 != null)
                      Container(
                        color: context.scaffoldBackgroundColor,
                        height: 300,
                        child: myBanner3 != null ? AdWidget(ad: myBanner3!) : SizedBox(),
                      ).paddingSymmetric(vertical: 16),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.post!.category.validate().map((e) {
                          if (e.name.validate() == "Education") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Education category
                                launchEducationURL();
                              },
                              child:
                              Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Entertainment News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchEntertainmentURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Lifestyle") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchLifestyleURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Fashion") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchFashionURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Health News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchHealthURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "People") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchPeopleURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Politics") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchPoliticsURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Religion News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchReligionURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Science News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchScienceURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Sports News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchSportsURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Technology News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchTechnologyURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Weired News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchWeiredURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Wellness and Fitness") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchWellnessURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "World News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchWorldURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Lottery News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchLotteryURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Business News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Fashion category
                                launchBusinessURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          else if (e.name.validate() == "Breaking News") {
                            return ElevatedButton(
                              onPressed: () {
                                // Open URL for Breaking category
                                launchBreakingURL();
                              },
                              child: Text(
                                'Read More on the Topic on TDPel Media',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Text(e.name.validate(), style: boldTextStyle(color: primaryColor));
                          }
                        }).toList(),
                      ),
                    ),
                    if (!isAdsDisabled && myBanner4 != null)
                      Container(
                        color: context.scaffoldBackgroundColor,
                        height: 300,
                        child: myBanner4 != null ? AdWidget(ad: myBanner4!) : SizedBox(),
                      ).paddingSymmetric(vertical: 16),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Copyright © 2023 TDPel Media',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    8.height,
                    Divider(color: Colors.grey.shade500, thickness: 0.3),
                    8.height,
                    ViewCommentWidget(id: widget.post!.iD.validate(), itemLength: 3),
                    if (widget.post!.postContent != null) Divider(color: Colors.grey.shade500, thickness: 0.1).paddingTop(8),
                    if (widget.post!.postContent != null) WriteCommentScreen(id: widget.post!.iD.validate()),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _isStickyBannerAdLoaded ? 50.0 : 0, // Set a custom height for the short rectangle banner
              child: _isStickyBannerAdLoaded ? AdWidget(ad: _stickyBanner!) : SizedBox(),
            ),
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: CommentButtonWidget(_scrollController),
          ),

        ],
      ),
    );
  }
}
