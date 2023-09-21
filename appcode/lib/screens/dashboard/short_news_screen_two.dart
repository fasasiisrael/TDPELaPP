import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/news/news_detail_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/utils/images.dart';

class ShortNewsScreen extends StatefulWidget {
  const ShortNewsScreen({Key? key}) : super(key: key);

  @override
  State<ShortNewsScreen> createState() => _ShortNewsScreenState();
}

class _ShortNewsScreenState extends State<ShortNewsScreen> with TickerProviderStateMixin {
  int page = 1;
  int recentNumPages = 1;
  List<PostModel> recentNewsListing = [];

  bool showBottom = true;
  int index = 0;

  late AnimationController _animationControllerNext;
  late AnimationController _animationControllerPrevious;

  @override
  void initState() {
    super.initState();

    _animationControllerNext = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _animationControllerNext.addStatusListener((status) {});

    _animationControllerPrevious = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    _animationControllerPrevious.addStatusListener((status) {});

    _animationControllerNext.value = 1;
    _animationControllerPrevious.value = 0;

    afterBuildCreated(() {
      setStatusBarColor(context.scaffoldBackgroundColor);
      getFeaturePostList();
    });
  }

  Future<void> getFeaturePostList() async {
    appStore.setLoading(true);

    await getDashboardApi(page).then((value) {
      if (page == 1) {
        recentNewsListing.clear();
      }
      recentNumPages = value.featureNumPages.validate();
      recentNewsListing.addAll(value.featurePost.validate());
      appStore.setLoading(false);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      log(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _animationControllerNext.dispose();
    _animationControllerPrevious.dispose();
    super.dispose();
  }

  void toggleNext() {
    if (index != recentNewsListing.length - 1) {
      _animationControllerNext.reverse().then((value) {
        _animationControllerNext.value = 1;
        index++;
        setState(() {});
      });
    }
  }

  void togglePrevious() {
    if (index != 0) {
      showBottom = false;
      setState(() {});

      _animationControllerPrevious.forward().then((value) {
        _animationControllerPrevious.value = 0;
        index--;
        showBottom = true;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.shortNews,
        color: appStore.isDarkMode ? appBackGroundColor : white,
        center: true,
        elevation: 0.2,
        backWidget: BackWidget(color: context.iconColor),
        actions: [
          TextButton(
            onPressed: () {
              NewsDetailScreen(
                post: recentNewsListing[index],
                newsId: recentNewsListing[index].iD.validate().toString(),
              ).launch(context);
            },
            child: Text(
              language.readMore,
              style: secondaryTextStyle(color: context.primaryColor),
              textAlign: TextAlign.end,
            ),
          ).paddingSymmetric(vertical: 10, horizontal: 8),
        ],
      ),
      body: Observer(
        builder: (_) => Stack(
          children: [
            if (!appStore.isLoading && recentNewsListing.isNotEmpty) placeHolderWidget(height: context.height() / 3, width: context.width(), fit: BoxFit.cover),
            if (recentNewsListing.isNotEmpty)
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _animationControllerPrevious,
                    builder: (BuildContext context, Widget? child) {
                      final angle = _animationControllerPrevious.value * pi;

                      return Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..setEntry(2, 2, 0.001)
                          ..rotateX(angle),
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy > 0) {
                              ///Scroll Down
                              togglePrevious();
                            } else {
                              ///Scroll Up
                              toggleNext();
                            }
                          },
                          onHorizontalDragUpdate: (details) {
                            //
                          },
                          child: SizedBox(
                            height: context.height() / 2.3,
                            child: angle <= 1.5708
                                ? Column(
                                    children: [
                                      cachedImage(
                                        recentNewsListing[index].image.validate(),
                                        height: context.height() / 3,
                                        width: context.width(),
                                        fit: BoxFit.cover,
                                      ),
                                      16.height,
                                      Text(
                                        parseHtmlString(recentNewsListing[index].postTitle.validate()),
                                        style: boldTextStyle(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ).paddingSymmetric(horizontal: 16),
                                    ],
                                  )
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationX(pi),
                                    child: Text(
                                      parseHtmlString(recentNewsListing[index].postContent.validate()).replaceAll('\n\n\n\n', '\n'),
                                      style: secondaryTextStyle(),
                                      maxLines: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ).paddingSymmetric(horizontal: 16),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _animationControllerNext,
                    builder: (BuildContext context, Widget? child) {
                      final angle = _animationControllerNext.value * pi;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(2, 2, 0.001)
                          ..rotateX(angle),
                        child: Transform(
                          transform: Matrix4.rotationX(pi),
                          child: GestureDetector(
                            onVerticalDragUpdate: (details) {
                              if (details.delta.dy > 0) {
                                ///Scroll Down
                                togglePrevious();
                              } else {
                                ///Scroll Up
                                toggleNext();
                              }
                            },
                            onHorizontalDragUpdate: (details) {
                              //
                            },
                            child: Container(
                              color: context.scaffoldBackgroundColor,
                              child: angle >= 1.5708
                                  ? Text(
                                      parseHtmlString(recentNewsListing[index].postContent.validate()).replaceAll('\n\n\n\n', '\n'),
                                      style: secondaryTextStyle(),
                                      maxLines: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ).paddingSymmetric(horizontal: 16)
                                  : Transform(
                                      transform: Matrix4.rotationX(pi),
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            cachedImage(
                                              recentNewsListing[index + 1].image.validate(),
                                              height: context.height() / 3,
                                              width: context.width(),
                                              fit: BoxFit.cover,
                                            ),
                                            16.height,
                                            Text(
                                              recentNewsListing[index + 1].postTitle.validate(),
                                              style: boldTextStyle(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ).paddingSymmetric(horizontal: 16),
                                          ],
                                        ),
                                        color: context.scaffoldBackgroundColor,
                                        height: context.height() / 2.3,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).visible(showBottom)
                ],
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  toggleNext();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language.next, style: primaryTextStyle()),
                    Icon(Icons.navigate_next, color: context.iconColor, size: 22),
                  ],
                ),
              ).paddingSymmetric(vertical: 16, horizontal: 8),
            ).visible(index != recentNewsListing.length - 1 && !appStore.isLoading && recentNewsListing.isNotEmpty),
            Align(
              alignment: Alignment.bottomLeft,
              child: TextButton(
                onPressed: () {
                  togglePrevious();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigate_before, color: context.iconColor, size: 22),
                    Text(language.previous, style: primaryTextStyle()),
                  ],
                ),
              ).paddingSymmetric(vertical: 16, horizontal: 8),
            ).visible(index != 0 && !appStore.isLoading && recentNewsListing.isNotEmpty),
            if (!appStore.isLoading && recentNewsListing.isEmpty) NoDataWidget(title: language.noRecordFound, image: ic_no_data).center(),
            Loader(color: primaryColor, valueColor: AlwaysStoppedAnimation(Colors.white)).center().visible(appStore.isLoading),
          ],
        ),
      ),
    );
  }
}
