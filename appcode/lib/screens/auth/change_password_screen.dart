import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/auth/sign_in_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';

import '../../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();

  var confirmPasswordCont = TextEditingController();
  var oldPasswordCont = TextEditingController();
  var newPasswordCont = TextEditingController();

  var newPasswordFocus = FocusNode();
  var confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  void validate() {
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);

      var request = {
        'password': oldPasswordCont.text,
        'new_password': confirmPasswordCont.text,
        'username': getStringAsync(USERNAME),
      };

      hideKeyboard(context);

      changePassword(request).then((res) {
        appStore.setLoading(false);
        toast('SuccessFully Change Your Password');
        SignInScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(language.changePassword, center: true, color: context.scaffoldBackgroundColor, elevation: 0.2, backWidget: BackWidget(color: context.iconColor)),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    AppTextField(
                      controller: oldPasswordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, language.oldPassword),
                      nextFocus: newPasswordFocus,
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                    16.height,
                    AppTextField(
                      controller: newPasswordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, language.newPassword),
                      focus: newPasswordFocus,
                      nextFocus: confirmPasswordFocus,
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                    16.height,
                    AppTextField(
                      controller: confirmPasswordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, language.confirmPassword),
                      focus: confirmPasswordFocus,
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                      validator: (v) {
                        if (v!.trim().isEmpty) return language.confirmPassword + language.fieldRequired;
                        if (v.trim() != newPasswordCont.text) return 'password does not match';

                        return null;
                      },
                    ),
                    24.height,
                    AppButton(
                      text: language.save,
                      textStyle: boldTextStyle(color: white_color),
                      width: context.width(),
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      color: primaryColor,
                      onTap: () {
                        hideKeyboard(context);
                        if (!accessAllowed) {
                          toast("Sorry");
                          return;
                        }
                        validate();
                      },
                    )
                  ],
                ).paddingAll(16.0),
              ),
            ),
            Observer(builder: (_) => Loader(color: primaryColor, valueColor: AlwaysStoppedAnimation(Colors.white)).center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
