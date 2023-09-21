import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/main.dart';

// ignore: must_be_immutable
class ForgetEmailDialog extends StatelessWidget {
  var email = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    void forgotPwdApi() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        hideKeyboard(context);

        var request = {
          'email': email.text,
        };

        appStore.setLoading(true);

        forgotPassword(request).then((res) {
          appStore.setLoading(false);
          toast('Successfully Send Email');
          finish(context);
        }).catchError((error) {
          appStore.setLoading(false);
          toast(error.toString());
        });
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: boxDecoration(context, color: white_color, radius: 10.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Text(language.forgotPassword, style: boldTextStyle(size: textSizeLargeMedium)),
                    24.height,
                    AppTextField(
                      controller: email,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: inputDecoration(context, language.emailAddress),
                      autoFocus: true,
                      validator: (s) {
                        if (s.validate().isEmpty) {
                          return errorThisFieldRequired;
                        }
                        return null;
                      },
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ],
                ).paddingOnly(left: 16.0, right: 16.0, bottom: 16.0),
                Container(
                  margin: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child: AppButton(
                    child: Text(language.send, style: primaryTextStyle(color: white_color, size: textSizeLargeMedium)),
                    color: primaryColor,
                    elevation: 0,
                    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    onTap: () {
                      if (!accessAllowed) {
                        toast(language.sorry);
                        return;
                      } else
                        appStore.setLoading(true);
                      forgotPwdApi();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
