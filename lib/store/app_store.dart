import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/language/app_localizations.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../main.dart';

part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isDarkMode = false;

  @observable
  String selectedLanguageCode = 'en';

  @observable
  bool isNotificationOn = true;

  @observable
  bool isLoggedIn = false;

  @observable
  String? userProfileImage = '';

  @observable
  String? userFirstName = '';

  @observable
  String? userLastName = '';

  @observable
  String? userEmail = '';

  @observable
  String? userLogin = '';

  @observable
  String userPassword = '';

  @observable
  int? userId = -1;

  @observable
  bool isLoading = false;

  @observable
  String languageForTTS = '';

  @observable
  String? userName = '';

  @observable
  double textFontSize = 14.0;

  @observable
  int fontSizeLevel = 1;

  @observable
  bool isScrolling = false;

  @observable
  bool isFeatureListEmpty = true;

  @action
  void setToScrolling(bool val) {
    isScrolling = val;
  }

  @action
  void setFeatureListEmpty(bool val) {
    isFeatureListEmpty = val;
  }

  @action
  void onFontSizeChange() {
    if (fontSizeLevel == 1) {
      fontSizeLevel = 2;
      textFontSize = 18.0;
    } else if (fontSizeLevel == 2) {
      fontSizeLevel = 3;
      textFontSize = 20.0;
    } else if (fontSizeLevel == 3) {
      fontSizeLevel = 4;
      textFontSize = 22.0;
    } else {
      fontSizeLevel = 1;
      textFontSize = 16.0;
    }
  }

  @action
  Future<void> setDarkMode(bool aIDarkMode) async {
    isDarkMode = aIDarkMode;
    await setValue(IS_DARK_THEME, aIDarkMode);

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      setStatusBarColor(appBackGroundColor /* ,statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.light*/);
    } else {
      textPrimaryColorGlobal = Colors.black;
      setStatusBarColor(white /*, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.dark*/);
    }
  }

  @action
  void setUserProfile(String? image) {
    userProfileImage = image;
  }

  @action
  void setUserId(int? val) {
    userId = val;
  }

  @action
  void setUserEmail(String? email) {
    userEmail = email;
  }

  @action
  void setFirstName(String? name) {
    userFirstName = name;
  }

  @action
  void setLastName(String? name) {
    userLastName = name;
  }

  @action
  void setUserLogin(String? name) {
    userLogin = name;
  }

  @action
  void setUserPassword(String name) {
    userPassword = name;
  }

  @action
  void setUserName(String name) {
    userName = name;
  }

  @action
  Future<void> setLoggedIn(bool val) async {
    isLoggedIn = val;
    await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  Future<void> setLanguage(String aSelectedLanguageCode, {BuildContext? context}) async {
    selectedLanguageCode = aSelectedLanguageCode;
    selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: defaultLanguage);
    selectedLanguageCode = getSelectedLanguageModel(defaultLanguage: defaultLanguage)!.languageCode!;
    language = await AppLocalizations().load(Locale(selectedLanguageCode));
  }

  @action
  void setNotification(bool val) {
    isNotificationOn = val;

    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      OneSignal.shared.disablePush(val);
    }
  }

  @action
  void setTTSLanguage(String lang) {
    languageForTTS = lang;
    setValue(TEXT_TO_SPEECH_LANG, lang);
  }
}
