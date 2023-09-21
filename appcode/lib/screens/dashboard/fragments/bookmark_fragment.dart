import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/components/loading_dot_widget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/model/post_list_model.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/news/components/news_item_widget.dart';
import 'package:news_flutter/screens/notifications/notification_list_screen.dart';
import 'package:news_flutter/shimmerScreen/news_item_shimmer.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';

class BookmarkFragment extends StatefulWidget {
  final bool? isTab;

  BookmarkFragment({this.isTab});

  @override
  BookmarkFragmentState createState() => BookmarkFragmentState();
}

class BookmarkFragmentState extends State<BookmarkFragment> {
  List<PostModel> bookMarkListing = [];
  ScrollController scrollController = ScrollController();

  bool isLoadAds = false;
  bool isLastPage = false;
  int page = 1;
  int numPages = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      appStore.setLoading(true);
      init();
    });

    scrollController.addListener(() {
      if ((scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        if (numPages > page) {
          page++;
          appStore.setLoading(true);

          setState(() {});
          getWishListData();
        }
      }
    });
  }

  init() async {
    getWishListData();

    if (allowPreFetched) {
      String res = getStringAsync(bookmarkData);

      if (res.isNotEmpty) {
        setData(PostListModel.fromJson(jsonDecode(res)));
      }
    }
  }

  Future<void> getWishListData() async {
    appStore.setLoading(true);

    await getWishList(page).then((res) async {
      await removeKey(bookmarkData);
      await setValue(bookmarkData, jsonEncode(res));
      setData(res);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
      setState(() {});
    });
  }

  void setData(PostListModel res) {
    afterBuildCreated(() {
      appStore.setLoading(false);
    });

    if (page == 1) {
      numPages = res.num_pages.validate();
      bookMarkListing.clear();
    }

    bookMarkListing.addAll(res.posts!);

    setState(() {});
    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Observer(builder: (context) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(top: context.statusBarHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bookmarkStore.mBookmark.isNotEmpty)
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          language.bookmark,
                          style: boldTextStyle(size: textSizeNormal),
                        ).paddingOnly(
                          left: 45,
                        ),
                        Spacer(),
                        IconButton(
                          icon: cachedImage(ic_notification, width: 22, height: 22, color: appStore.isDarkMode ? Colors.white : Colors.black),
                          onPressed: () {
                            NotificationListScreen().launch(context);
                          },
                        ),
                      ],
                    ).paddingOnly(top: 5),
                  if (bookmarkStore.mBookmark.isNotEmpty)
                    AnimatedListView(
                      slideConfiguration: SlideConfiguration(delay: 250.milliseconds, curve: Curves.easeOutQuad, verticalOffset: context.height() * 0.1),
                      itemCount: bookmarkStore.mBookmark.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(8),
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        PostModel post = bookmarkStore.mBookmark[i];

                        return NewsItemWidget(post, index: i);
                      },
                    ).paddingOnly(top: 8.0, bottom: 16.0),
                ],
              ),
            );
          }),
          Observer(builder: (context) => NoDataWidget(title: language.bookmarkpage, image: ic_no_data).center().visible(!appStore.isLoading && bookmarkStore.mBookmark.isEmpty)),
          Observer(builder: (context) => NewsItemShimmer().visible(appStore.isLoading && page == 1 && bookmarkStore.mBookmark.isEmpty)),
          Observer(builder: (context) => LoadingDotsWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
