import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/model/base_response.dart' as b;
import 'package:news_flutter/model/post_list_model.dart';
import 'package:news_flutter/model/category_model.dart';
import 'package:news_flutter/model/dashboard_model.dart';
import 'package:news_flutter/model/login_response.dart';
import 'package:news_flutter/model/notification_model.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/model/view_comment_model.dart';
import 'package:news_flutter/model/weather_model.dart';
import 'package:news_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:news_flutter/utils/constant.dart';

import '../main.dart';
import 'network_utils.dart';

Future<bool> handlePermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  final GeolocatorPlatform geoLocator = GeolocatorPlatform.instance;

  serviceEnabled = await geoLocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }
  permission = await geoLocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await geoLocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }
  return true;
}

Future<WeatherModel> weatherApi() async {
  final hasPermission = await handlePermission();

  if (!hasPermission) {
    throw permission;
  }
  final GeolocatorPlatform geoLocator = GeolocatorPlatform.instance;
  final Position position = await geoLocator.getCurrentPosition();
  http.Response response = await http.get(Uri.parse('$weatherUrl?key=$weatherApiKey&days=7&q=${position.latitude},${position.longitude}&aqi=yes'));
  if (response.statusCode.isSuccessful()) {
    return WeatherModel.fromJson(jsonDecode(response.body));
  } else {
    throw errorMsg;
  }
}

Future<LoginResponse> login(Map request, {bool isSocialLogin = false}) async {
  Response response = await postRequest(isSocialLogin ? 'iqonic-api/api/v1/customer/social_login' : 'jwt-auth/v1/token', request);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      if (jsonDecode(response.body).containsKey('code')) {
        if (jsonDecode(response.body)['code'].toString().contains('invalid_username')) {
          throw 'invalid_username';
        }
      }
    }
  }

  return await handleResponse(response).then((res) async {
    if (res.containsKey('code')) {
      if (res['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }

    LoginResponse loginResponse = LoginResponse.fromJson(res);

    await setValue(USER_ID, loginResponse.userId);
    await setValue(FIRST_NAME, loginResponse.firstName);
    await setValue(LAST_NAME, loginResponse.lastName);
    await setValue(USER_EMAIL, loginResponse.userEmail);
    await setValue(USERNAME, loginResponse.userNiceName);
    await setValue(TOKEN, loginResponse.token);
    await setValue(USER_DISPLAY_NAME, loginResponse.userDisplayName);
    await setValue(USER_LOGIN, loginResponse.userLogin);
    await setValue(IS_SOCIAL_LOGIN, isSocialLogin.validate());
    await setValue(IS_LOGGED_IN, true);

    if (loginResponse.profileImage!.isNotEmpty) {
      await setValue(PROFILE_IMAGE, loginResponse.profileImage.validate());
    } else {
      await setValue(PROFILE_IMAGE, appStore.userProfileImage.validate());
    }

    appStore.setUserId(loginResponse.userId);
    appStore.setUserEmail(loginResponse.userEmail);
    appStore.setFirstName(loginResponse.firstName);
    appStore.setLastName(loginResponse.lastName);
    appStore.setUserLogin(loginResponse.userLogin);
    appStore.setUserName(loginResponse.userNiceName.validate());
    if (loginResponse.profileImage!.isNotEmpty) {
      appStore.setUserProfile(loginResponse.profileImage.validate());
    }
    appStore.setLoggedIn(true);

    if (bookmarkStore.mBookmark.isNotEmpty) bookmarkStore.mBookmark.clear();

    if (isSocialLogin) {
      FirebaseAuth.instance.signOut();
      await setValue(IS_REMEMBERED, true);
    } else {
      appStore.setUserProfile(loginResponse.profileImage);
    }
    return loginResponse;
  }).catchError((e) {
    log(e);
    throw e.toString();
  });
}

Future<void> createUser(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/registration', request, requireToken: false));
}

Future updateUser(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/registration', request, requireToken: false));
}

Future<DashboardModel> getDashboardApi(int page) async {
  var res = DashboardModel.fromJson(await handleResponse(await getRequest('iqonic-api/api/v1/blog/get-dashboard?page=$page&posts_per_page=40', requireToken: false)));

  if (res.socialLink != null) {
    await setValue(WHATSAPP, res.socialLink!.whatsapp.toString());
    await setValue(FACEBOOK, res.socialLink!.facebook.toString());
    await setValue(TWITTER, res.socialLink!.twitter.toString());
    await setValue(INSTAGRAM, res.socialLink!.instagram.toString());
    await setValue(CONTACT, res.socialLink!.contact.toString());

    if (res.socialLink!.termCondition.validate().isNotEmpty) {
      await setValue(TERMS_AND_CONDITIONS, res.socialLink!.termCondition.toString());
    } else {
      await setValue(TERMS_AND_CONDITIONS, TERMS_CONDITION);
    }
    if (res.socialLink!.privacyPolicy.validate().isNotEmpty) {
      await setValue(PRIVACY_POLICY, res.socialLink!.privacyPolicy.toString());
    } else {
      await setValue(PRIVACY_POLICY, POLICY);
    }
    await setValue(COPYRIGHT_TEXT, res.socialLink!.copyrightText.toString());
  }

  /// if you want language set under the app so comment this two line other wise uncomment..
  if (!isLanguageEnable) {
    setValue(LANGUAGE, res.appLang.toString());
    appStore.setLanguage(res.appLang.toString());
  }

  String featureNewsMarquee = "";

  if (res.featurePost.validate().isNotEmpty) {
    appStore.setFeatureListEmpty(false);
  } else {
    appStore.setFeatureListEmpty(true);
  }

  res.featurePost.validate().take(5).forEach((e) {
    featureNewsMarquee = featureNewsMarquee + e.postTitle.validate() + " | ";
  });

  res.featureNewsMarquee = featureNewsMarquee;

  return res;
}

Future<PostModel> getBlogDetail(Map request) async {
  return PostModel.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/get-post-details', request, requireToken: appStore.isLoggedIn ? true : false)));
}

Future saveProfileImage(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/save-profile-image', request, requireToken: true));
}

Future<List<CategoryModel>> getCategories({int? page, int perPage = perPageCategory, int? parent}) async {
  Iterable it = await handleResponse(await getRequest('wp/v2/get-category?parent=${parent ?? 0}&page=${page ?? 1}&per_page=$perPage', requireToken: false));
  return it.map((e) => CategoryModel.fromJson(e)).toList();
}

Future<PostListModel> getBlogList(Map request, int page) async {
  return PostListModel.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/get-blog-by-filter/?posts_per_page=40&page=$page', request, requireToken: true)));
}

Future<PostListModel> getSearchBlogList(Map request, int page) async {
  return PostListModel.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/get-blog-by-filter?page=$page', request)));
}

Future<b.BaseResponse> addWishList(Map request) async {
  return b.BaseResponse.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/add-fav-list', request, requireToken: true)));
}

Future<PostListModel> getWishList(int page) async {
  return PostListModel.fromJson(await handleResponse(await postRequest('iqonic-api/api/v1/blog/get-fav-list?page=$page&posts_per_page=50', {}, requireToken: true)));
}

Future<void> removeWishList(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/delete-fav-list', request, requireToken: true));
}

Future<List<ViewCommentModel>> getCommentList(int id, {int? page}) async {
  List<String> params = [];
  if (page != null) {
    params.add('page=$page');
    params.add('per_page=$PER_PAGE');
  }

  Iterable it = await handleResponse(await getRequest('wp/v2/comments?post=$id&${params.validate().join('&')}', requireToken: false));
  return it.map((e) => ViewCommentModel.fromJson(e)).toList();
}

Future updateCommentList(Map request) async {
  await handleResponse(await postRequest('iqonic-api/api/v1/blog/comment', request, requireToken: true));
}

Future<void> deleteCommentList(Map request) async {
  await handleResponse(await postRequest('iqonic-api/api/v1/blog/comment-delete', request, requireToken: true));
}

Future postComment(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/post-comment', request, requireToken: true));
}

Future<void> forgotPassword(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/forget-password', request));
}

Future getVideoList(Map request, int page) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/blog/get-video-list?paged=$page&per_page=10', request, requireToken: false));
}

Future<void> changePassword(Map request) async {
  return handleResponse(await postRequest('iqonic-api/api/v1/user/change-password', request, requireToken: true));
}

Future<NotificationModel> getNotificationList() async {
  return NotificationModel.fromJson(await handleResponse(await getRequest('iqonic-api/api/v1/blog/get-notification-list', requireToken: false)));
}

Future<void> logout(BuildContext context) async {
  await removeKey(TOKEN);
  await removeKey(USER_ID);
  await removeKey(FIRST_NAME);
  await removeKey(LAST_NAME);
  await removeKey(USERNAME);
  await removeKey(USER_DISPLAY_NAME);
  await removeKey(PROFILE_IMAGE);
  await removeKey(USER_EMAIL);
  await removeKey(IS_LOGGED_IN);
  await removeKey(IS_SOCIAL_LOGIN);
  await removeKey(USER_LOGIN);

  if (getBoolAsync(IS_SOCIAL_LOGIN) || !getBoolAsync(IS_REMEMBERED)) {
    await removeKey(USER_PASSWORD);
    await removeKey(USER_EMAIL_USERNAME);
  }
  bookmarkStore.clearBookmark();
  //
  appStore.setLoggedIn(false);
  appStore.setUserId(0);
  appStore.setUserEmail('');
  appStore.setFirstName('');
  appStore.setLastName('');
  appStore.setUserLogin('');
  appStore.setUserName('');
  appStore.setUserProfile('');
  //

  DashboardScreen().launch(context, isNewTask: true);
}
