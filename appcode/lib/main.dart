import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_theme.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/language/app_localizations.dart';
import 'package:news_flutter/language/languages.dart';
import 'package:news_flutter/model/post_model.dart';
import 'package:news_flutter/screens/news/news_detail_screen.dart';
import 'package:news_flutter/screens/notifications/web_view_screen.dart';
import 'package:news_flutter/screens/splash_screen.dart';
import 'package:news_flutter/store/app_store.dart';
import 'package:news_flutter/store/bookmark/bookmark_store.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'model/language_model.dart';
import 'package:firebase_analytics/observer.dart';

late PackageInfoData packageInfo;

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

AppStore appStore = AppStore();
BookmarkStore bookmarkStore = BookmarkStore();

int mInterstitialAdCount = 0;

late BaseLanguage language;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize(aLocaleLanguageList: getLanguages());
  await Firebase.initializeApp();

  if (isMobile) {
    await Firebase.initializeApp().then((value) async {
      MobileAds.instance.initialize();

      await OneSignal.shared.setAppId(ONESIGNAL_APP_ID);
      OneSignal.shared.setNotificationOpenedHandler((openedResult) {
        //
      });

      OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
        event.complete(event.notification);
      });

      OneSignal.shared.consentGranted(true);
      OneSignal.shared.promptUserForPushNotificationPermission();
    }).catchError(onError);

    await setupFirebaseRemoteConfig().then((remoteConfig) async {
      if (isIOS) {
        await setValue(HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_APP_STORE_REVIEW));
      } else if (isAndroid) {
        await setValue(HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_PLAY_STORE_REVIEW));
      }
    }).catchError((e) {
      toast(e.toString());
    });
  }

  packageInfo = await getPackageInfo();

  defaultRadius = 12.0;

  appStore.setDarkMode(getBoolAsync(IS_DARK_THEME));
  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));
  appStore.setTTSLanguage(getStringAsync(TEXT_TO_SPEECH_LANG, defaultValue: defaultTTSLanguage));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  String bookmarkString = getStringAsync(WISHLIST_ITEM_LIST);
  if (bookmarkString.isNotEmpty) {
    bookmarkStore.addAllBookmark(jsonDecode(bookmarkString).map<PostModel>((e) => PostModel.fromJson(e)).toList());
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setOrientationPortrait();

    afterBuildCreated(() {
      OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification) {
        try {
          var notId = notification.notification.additionalData!.containsKey('id') ? notification.notification.additionalData!['id'] : 0;
          if (notId.toString().isNotEmpty) {
            push(NewsDetailScreen(newsId: notId.toString()));
          } else {
            if (notification.notification.additionalData!.containsKey('video_url')) {
              String? videoUrl = notification.notification.additionalData!['video_url'];
              String? videoType = notification.notification.additionalData!['video_type'];
              push(WebViewScreen(videoUrl: videoUrl, videoType: videoType));
            }
          }
        } catch (e) {
          throw errorSomethingWentWrong;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        navigatorObservers: [observer],
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode.validate(value: defaultLanguage)),
        home: SplashScreen(),
      ),
    );
  }
}
