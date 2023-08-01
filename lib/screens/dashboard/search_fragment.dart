import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/components/loading_dot_widget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/news/components/news_item_widget.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/images.dart';
import 'package:stream_transform/stream_transform.dart';

class SearchFragment extends StatefulWidget {
  @override
  _SearchFragmentState createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> with WidgetsBindingObserver {
  List<PostModel> searchList = [];
  TextEditingController searchCont = TextEditingController();
  FocusNode searchNode = FocusNode();
  ScrollController scrollController = ScrollController();
  int page = 1;
  int numPages = 0;

  StreamController<String> searchStream = StreamController();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
    searchStream.stream.debounce(Duration(seconds: 2)).listen((s) {
      getSearchListing();
    });
  }

  Future<void> init() async {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (numPages > page) {
          page++;
          getSearchListing();
        }
      }
    });
  }

  Future<void> getSearchListing() async {
    Map req = {
      "text": searchCont.text,
    };
    appStore.setLoading(true);
    await getSearchBlogList(req, page).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      if (page == 1) searchList.clear();
      searchList.addAll(res.posts.validate());

      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log("Error: ${error.toString()}");
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchStream.close();
    searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await 2.seconds.delay;
        setState(() {});
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: context.scaffoldBackgroundColor,
          titleSpacing: 0,
          leading: BackWidget(color: context.iconColor),
          title: TextField(
            textAlignVertical: TextAlignVertical.center,
            controller: searchCont,
            focusNode: searchNode,
            textInputAction: TextInputAction.done,
            cursorColor: primaryColor,
            style: primaryTextStyle(),
            onChanged: (String searchTxt) async {
              searchStream.add(searchTxt);
            },
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: context.scaffoldBackgroundColor,
              border: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: primaryTextStyle(),
              hintText: language.search,
            ),
          ),
          actions: [
            if (searchCont.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close),
                color: primaryColor,
                onPressed: () {
                  searchCont.clear();
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (searchList.isNotEmpty) Text(language.found, style: boldTextStyle(size: 18)).paddingAll(16),
                AnimatedListView(
                  controller: scrollController,
                  slideConfiguration: SlideConfiguration(delay: 250.milliseconds, curve: Curves.easeOutQuad, verticalOffset: context.height() * 0.1),
                  padding: EdgeInsets.all(8),
                  itemCount: searchList.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  onNextPage: () {
                    page += 1;
                    getSearchListing();
                  },
                  itemBuilder: (context, i) => NewsItemWidget(searchList[i], index: i),
                ).expand(),
              ],
            ),
            if (searchList.isEmpty && !appStore.isLoading)
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: NoDataWidget(
                  title: language.noRecordFound,
                  image: ic_no_data,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: page < 1 ? 0 : null,
              child: Observer(builder: (context) {
                return page < 1
                    ? LoadingDotsWidget().visible(appStore.isLoading)
                    : ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0, tileMode: TileMode.mirror),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: LoadingDotsWidget(),
                      color: context.cardColor.withOpacity(0.3),
                    ),
                  ),
                ).visible(appStore.isLoading);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
