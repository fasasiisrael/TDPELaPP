import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/auth/sign_in_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';

class WriteCommentScreen extends StatefulWidget {
  final int? id;
  final bool hideTitle;
  final String? editCommentText;
  final bool isUpdate;
  final int? commentId;

  WriteCommentScreen({this.id, this.hideTitle = false, this.editCommentText, this.isUpdate = false, this.commentId});

  @override
  _WriteCommentScreenState createState() => _WriteCommentScreenState();
}

class _WriteCommentScreenState extends State<WriteCommentScreen> {
  TextEditingController commentCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (widget.editCommentText.validate().isNotEmpty) {
      commentCont.text = widget.editCommentText.toString();
    }
  }

  Future<void> postCommentApi() async {
    hideKeyboard(context);

    appStore.setLoading(true);
    if (widget.isUpdate) {
      var request = {"content": commentCont.text.trim().validate(), "id": widget.commentId};

      await updateCommentList(request).then((res) {
        appStore.setLoading(false);
        LiveStream().emit("ChangeComment");
        toast("Comment has been updated");
        finish(context);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    } else {
      var request = {
        'comment_content': commentCont.text.trim().validate(),
        'comment_post_ID': widget.id,
      };

      await postComment(request).then((res) {
        appStore.setLoading(false);
        toast(res['message']);
        LiveStream().emit("AddComment");
        commentCont.clear();
        setState(() {});
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(8), backgroundColor: context.scaffoldBackgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.hideTitle) Text(language.updateComment, style: boldTextStyle()).paddingOnly(left: 16, top: 16),
              AppTextField(
                textFieldType: TextFieldType.MULTILINE,
                controller: commentCont,
                scrollPadding: EdgeInsets.all(16.0),
                keyboardType: TextInputType.multiline,
                minLines: widget.hideTitle ? 4 : 1,
                decoration: InputDecoration(
                  labelText: widget.hideTitle ? "" : language.comment,
                  labelStyle: secondaryTextStyle(),
                  enabledBorder: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: radius(editTextRadius),
                    borderSide: BorderSide(color: viewLineColor, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: radius(editTextRadius),
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: radius(editTextRadius),
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                  ),
                  errorMaxLines: 2,
                  errorStyle: primaryTextStyle(color: Colors.red, size: 12),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: radius(editTextRadius),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),

                  /// add observer
                  suffixIcon: widget.hideTitle
                      ? SizedBox()
                      : IconButton(
                          padding: EdgeInsets.all(0),
                          icon: cachedImage(ic_send, color: primaryColor, height: 24, width: 24),
                          onPressed: () {
                            if (!accessAllowed) {
                              toast(language.sorry);
                              return;
                            }
                            if (commentCont.text.isEmpty) {
                              toast("Comment " + Field_Required);
                            } else {
                              if (appStore.isLoggedIn) {
                                postCommentApi();
                              } else {
                                SignInScreen().launch(context);
                              }
                            }
                          },
                        ),
                ),
              ).paddingAll(16),
              if (widget.hideTitle)
                Observer(
                  builder: (_) => Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          onTap: () {
                            finish(context);
                          },
                          elevation: 0,
                          child: Text(language.cancel, style: boldTextStyle(color: appStore.isDarkMode ? white : black)),
                          color: context.cardColor,
                        ),
                        16.width,
                        AppButton(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            elevation: 0,
                            onTap: () {
                              if (!accessAllowed) {
                                toast(language.sorry);
                                return;
                              }
                              if (commentCont.text.isEmpty) {
                                toast("Comment " + Field_Required);
                              } else {
                                if (appStore.isLoggedIn) {
                                  postCommentApi();
                                } else {
                                  SignInScreen().launch(context);
                                }
                              }
                            },
                            child: Text(language.send, style: boldTextStyle(color: white)),
                            color: primaryColor)
                      ],
                    ).paddingOnly(bottom: 8, right: 16),
                  ),
                ),
            ],
          ),
        ),
        if (widget.hideTitle) Positioned(right: 0, top: 0, bottom: 0, left: 0, child: Loader(color: primaryColor, valueColor: AlwaysStoppedAnimation(Colors.white)).visible(appStore.isLoading))
      ],
    );
  }
}
