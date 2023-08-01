import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/network/auth_service.dart';
import 'package:news_flutter/screens/auth/components/otp_dialog_box.dart';
import 'package:news_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';

class SocialButtons extends StatefulWidget {
  const SocialButtons({Key? key}) : super(key: key);

  @override
  State<SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          width: context.width(),
          color: context.cardColor,
          elevation: 0,
          shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GoogleLogoWidget(size: 18),
              16.width,
              Text(language.google, style: secondaryTextStyle(size: textSizeLargeMedium)),
            ],
          ),
          onTap: () async {
            appStore.setLoading(true);

            await LogInWithGoogle().then((user) async {
              appStore.setLoading(false);

              DashboardScreen().launch(context, isNewTask: true);
            }).catchError((e) {
              appStore.setLoading(false);
              log("Error : ${e.toString()}");

              throw errorSomethingWentWrong;
            });
          },
          margin: EdgeInsets.symmetric(horizontal: 16),
        ),
        16.height,
        AppButton(
          width: context.width(),
          color: context.cardColor,
          elevation: 0,
          shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(ic_call_ring, color: appStore.isDarkMode ? white : primaryColor, width: 22, height: 22),
              16.width,
              Text(language.phoneNumber, style: secondaryTextStyle(size: textSizeLargeMedium)),
            ],
          ),
          onTap: () async {
            await showInDialog(
              context,
              builder: (_) => OTPDialogBox(),
              shape: dialogShape(),
              backgroundColor: context.scaffoldBackgroundColor,
              barrierDismissible: false,
            ).catchError((e) {
              toast(e.toString());
            });
          },
          margin: EdgeInsets.symmetric(horizontal: 16),
        ),
        if (isIOS)
          AppButton(
            width: context.width(),
            elevation: 0,
            color: appStore.isDarkMode ? appBackGroundColor : Colors.grey.shade200,
            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(ic_apple, color: appStore.isDarkMode ? white : black, width: 24, height: 24),
                8.width,
                Text(language.apple, style: primaryTextStyle(size: textSizeLargeMedium)),
              ],
            ),
            onTap: () async {
              appStore.setLoading(true);

              await appleSignIn().then((value) {
                appStore.setLoading(false);

                DashboardScreen().launch(context, isNewTask: true);
              }).catchError((e) {
                toast(e.toString());
                appStore.setLoading(false);
                setState(() {});
              });
            },
            margin: EdgeInsets.all(16),
          ),
      ],
    );
  }
}
