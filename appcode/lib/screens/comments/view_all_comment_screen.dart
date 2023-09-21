import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/model/view_comment_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/comments/write_comment_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/components/loading_dot_widget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/utils/images.dart';

class ViewAllCommentScreen extends StatefulWidget {
  final int? id;

  ViewAllCommentScreen({required this.id});

  @override
  _ViewAllCommentScreenState createState() => _ViewAllCommentScreenState();
}

class _ViewAllCommentScreenState extends State<ViewAllCommentScreen> {
  ScrollController _scrollController = ScrollController();

  Future<List<ViewCommentModel>>? future;

  List<ViewCommentModel> commentList = [];

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = _getCommentList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage && commentList.isNotEmpty) {
          mPage++;
          future = _getCommentList();
        }
      }
    });
    // LiveStream().on("ChangeComment", (p0) {
    //   setState(() {});
    // });
  }

  Future<List<ViewCommentModel>> _getCommentList() async {
    appStore.setLoading(true);

    await getCommentList(widget.id.validate(), page: mPage).then((value) {
      if (mPage == 1) commentList.clear();

      mIsLastPage = value.length != 20;
      commentList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    });

    return commentList;
  }

  Future<void> deleteComment({int? id}) async {
    Map req = {"id": id};

    appStore.setLoading(true);

    await deleteCommentList(req).then((value) {
      appStore.setLoading(false);
      LiveStream().emit("deleteComment");
      toast("Comment has been deleted");
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.comments,
        color: appStore.isDarkMode ? appBackGroundColor : white,
        backWidget: BackWidget(color: context.iconColor),
        elevation: 0.2,
        center: true,
      ),
      body: FutureBuilder<List<ViewCommentModel>>(
        future: future,
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data!.length == 0) {
              return NoDataWidget(title: language.noRecordFound, image: ic_no_data).center();
            } else {
              return AnimatedListView(
                itemCount: snap.data.validate().length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(16),
                slideConfiguration: SlideConfiguration(delay: 250.milliseconds, curve: Curves.easeOutQuad, verticalOffset: context.height() * 0.1),
                itemBuilder: (context, i) {
                  ViewCommentModel data = snap.data![i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      8.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            decoration: boxDecoration(context, bgColor: Colors.grey, radius: 23.0),
                            child: cachedImage(
                              data.author == appStore.userId ? appStore.userProfileImage.validate() : data.author_avatar_urls!.avatarFortyEight.toString(),
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(24),
                          ),
                          16.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.authorName.validate().capitalizeFirstLetter(),
                                style: boldTextStyle(size: textSizeMedium),
                                maxLines: 2,
                              ),
                              4.height,
                              Text(
                                data.date != null ? convertDate(data.date) : '',
                                style: secondaryTextStyle(size: 10),
                              ),
                            ],
                          ),
                          Spacer(),
                          if (data.author == appStore.userId)
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: WriteCommentScreen(
                                            id: widget.id.validate(),
                                            hideTitle: true,
                                            commentId: data.id,
                                            isUpdate: true,
                                            editCommentText: parseHtmlString(data.content!.rendered),
                                          ),
                                        );
                                      },
                                    );
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showConfirmDialogCustom(
                                      context,
                                      title: language.deleteComment,
                                      primaryColor: primaryColor,
                                      onAccept: (c) async {
                                        deleteComment(id: data.id);
                                      },
                                      dialogType: DialogType.DELETE,
                                      negativeText: language.no,
                                      positiveText: language.yes,
                                    );
                                  },
                                  icon: Icon(Icons.delete),
                                )
                              ],
                            )
                        ],
                      ),
                      8.height,
                      ReadMoreText(
                        parseHtmlString(
                          data.content!.rendered != null ? data.content!.rendered : '',
                        ),
                        trimLines: 2,
                        style: secondaryTextStyle(size: textSizeSMedium),
                        colorClickableText: primaryColor,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: '...${language.readMore}',
                        trimExpandedText: language.readLess,
                      ),
                      if (data.content!.rendered.validate().isNotEmpty && data.content!.rendered.validate().length > 40) 16.height,
                      Divider(color: Colors.grey.shade500, thickness: 0.1),
                    ],
                  );
                },
              );
            }
          }
          if (snap.hasError) {
            return NoDataWidget(title: language.somethingWentWrong, image: ic_no_data);
          }
          return LoadingDotsWidget().center();
        },
      ),
    );
  }
}
