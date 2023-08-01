import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/network/auth_service.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/auth/sign_up_screen.dart';
import 'package:news_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';

class OTPDialogBox extends StatefulWidget {
  static String tag = '/OTPDialog';
  final String? verificationId;
  final String? phoneNumber;
  final bool? isCodeSent;
  final PhoneAuthCredential? credential;

  OTPDialogBox({this.verificationId, this.isCodeSent, this.phoneNumber, this.credential});

  @override
  OTPDialogBoxState createState() => OTPDialogBoxState();
}

class OTPDialogBoxState extends State<OTPDialogBox> {
  TextEditingController numberController = TextEditingController();

  String otpCode = '';

  Country selectedCountry = defaultCountry();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  //region Methods
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      showPhoneCode: true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        log(jsonEncode(selectedCountry.toJson()));
        setState(() {});
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> submit() async {
    appStore.setLoading(true);
    setState(() {});

    AuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: otpCode.validate());

    await FirebaseAuth.instance.signInWithCredential(credential).then((result) async {
      Map req = {
        'username': widget.phoneNumber!.replaceAll('+', ''),
        'password': widget.phoneNumber!.replaceAll('+', ''),
      };

      appStore.setLoading(true);
      await login(req).then((value) async {
        appStore.setLoading(false);

        await setValue(IS_SOCIAL_LOGIN, true);
        await setValue(LOGIN_TYPE, SignInTypeOTP);
        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((e) {
        appStore.setLoading(false);
        if (e.toString().contains('invalid_username')) {
          finish(context);
          finish(context);
          SignUpScreen(phoneNumber: widget.phoneNumber!.replaceAll('+', '')).launch(context);
        } else {
          toast(e.toString());
        }
      });
    }).catchError((e) {
      toast(errorSomethingWentWrong);
      appStore.setLoading(false);
      setState(() {});
    });
  }

  Future<void> sendOTP() async {
    if (numberController.text.trim().isEmpty) {
      return toast(errorThisFieldRequired);
    }
    appStore.setLoading(true);
    setState(() {});
    String number = '+${selectedCountry.phoneCode}${numberController.text.trim()}';
    if (!number.startsWith('+')) {
      number = '+${selectedCountry.phoneCode}${numberController.text.trim()}';
    }

    await signInWithOTP(context, number).then((value) {
      //
    }).catchError((e) {
      toast(e.toString());
    });

    appStore.setLoading(false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      child: !widget.isCodeSent.validate()
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.enterPhoneNumber, style: boldTextStyle()),
                24.height,
                AppTextField(
                  controller: numberController,
                  textFieldType: TextFieldType.PHONE,
                  decoration: inputDecoration(context, language.phoneNumber).copyWith(
                    prefixText: '+${selectedCountry.phoneCode} ',
                    hintText: 'Example: ${selectedCountry.example}',
                  ),
                  autoFocus: true,
                  cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                  onFieldSubmitted: (s) {
                    sendOTP();
                  },
                ),
                16.height,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      changeCountry();
                    },
                    child: Text("Change country", style: secondaryTextStyle(size: 16)),
                  ),
                ),
                16.height,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AppButton(
                      onTap: () {
                        sendOTP();
                        hideKeyboard(context);
                      },
                      text: language.sendotp,
                      width: context.width(),
                      color: primaryColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      textStyle: primaryTextStyle(color: white_color, size: textSizeLargeMedium),
                    ),
                    Positioned(
                      //right: 16,
                      child: Observer(builder: (_) => Loader(color: primaryColor, valueColor: AlwaysStoppedAnimation(Colors.white)).visible(appStore.isLoading)),
                    ),
                  ],
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.otpReceived, style: boldTextStyle()),
                30.height,
                OTPTextField(
                  pinLength: 6,
                  fieldWidth: 35,
                  onChanged: (s) {
                    otpCode = s;
                  },
                  onCompleted: (pin) {
                    otpCode = pin;
                    submit();
                  },
                ).fit(),
                30.height,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AppButton(
                      onTap: () {
                        submit();
                      },
                      child: Text(language.confirm, style: boldTextStyle(color: white)),
                      color: primaryColor,
                      width: context.width(),
                    ),
                    Positioned(
                      child: Observer(builder: (_) => Loader().visible(appStore.isLoading)),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
