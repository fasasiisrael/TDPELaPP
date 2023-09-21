import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get splashSubTitle;

  String get found;

  String get previous;

  String get next;

  String get shortNews;

  String get watchLiveNews;

  String get clickToRefresh;

  String get updateComment;

  String get deleteComment;

  String get readFullArticle;

  String get windSpeed;

  String get sunrise;

  String get sunset;

  String get thisWeek;

  String get majorAirPollutant;

  String get appSetting;

  String get notificationSetting;

  String get editProfile;

  String get accountSetting;

  String get latestNews;

  String get featuredNews;

  String get seeAll;

  String get categories;

  String get contactUs;

  String get nightMode;

  String get share;

  String get logout;

  String get titleForSignIn;

  String get welcomeMsgForSignIn;

  String get password;

  String get confirmPassword;

  String get termCondition;

  String get terms;

  String get signIn;

  String get signUp;

  String get dontHaveAccount;

  String get haveAnAccount;

  String get bookmarkpage;

  String get gettingStarted;

  String get createAnAccountContinue;

  String get comment;

  String get send;

  String get search;

  String get profile;

  String get userName;

  String get firstName;

  String get lastName;

  String get email;

  String get emailAddress;

  String get save;

  String get settings;

  String get language;

  String get changePassword;

  String get forgotPassword;

  String get newPassword;

  String get oldPassword;

  String get fieldRequired;

  String get successFullyRegister;

  String get conformationUploadImage;

  String get sorry;

  String get yes;

  String get no;

  String get about;

  String get version;

  String get followUs;

  String get bookmark;

  String get rememberME;

  String get invalidEmail;

  String get passwordLength;

  String get acceptTerms;

  String get somethingWentWrong;

  String get fontSize;

  String get enable;

  String get disable;

  String get pushNotification;

  String get logoutConfirmation;

  String get sendotp;

  String get phoneNumber;

  String get enterPhoneNumber;

  String get confirm;

  String get otpReceived;

  String get allowPrefetching;

  String get testToSpeechLanguage;

  String get chooseDetailPageVariant;

  String get by;

  String get variant;

  String get signInWith;

  String get readMore;

  String get readLess;

  String get ourWebsite;

  String get px;

  String get comments;

  String get notification;

  String get searchYourNews;

  String get weHaveFound;

  String get purchase;

  String get cancel;

  String get google;

  String get apple;

  String get noRecordFound;
}
