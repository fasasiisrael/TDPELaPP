import 'package:country_picker/country_picker.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tab;
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'colors.dart';
import 'constant.dart';


Future<FirebaseRemoteConfig> setupFirebaseRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
  await remoteConfig.fetch();
  await remoteConfig.fetchAndActivate();

  return remoteConfig;
}

String convertDate(date) {
  try {
    return date != null ? DateFormat(dateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    print(e);
    return '';
  }
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

void redirectUrl(url) async {
  await url_launcher.launchUrl(Uri.parse(url));
}

Future<void> launchUrl(String url) async {
  try {
    await custom_tab.launch(
      url,
      customTabsOption: custom_tab.CustomTabsOption(
        toolbarColor: primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: custom_tab.CustomTabsSystemAnimation.slideIn(),
        extraCustomTabs: const <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
        ],
      ),
      safariVCOption: custom_tab.SafariViewControllerOption(
        preferredBarTintColor: primaryColor,
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle: custom_tab.SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}

InputDecoration inputDecoration(
  BuildContext context,
  String? hint, {
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool prefix = false,
  bool suffix = false,
  VoidCallback? onIconTap,
  double? borderRadius,
}) {
  return InputDecoration(
    prefixIcon: prefix ? prefixIcon.paddingAll(12) : null,
    suffixIcon: suffix ? suffixIcon.onTap(() => onIconTap?.call()).paddingAll(12) : null,
    labelText: hint,
    labelStyle: secondaryTextStyle(),
    enabledBorder: OutlineInputBorder(
      gapPadding: 0,
      borderRadius: radius(borderRadius ?? editTextRadius),
      borderSide: BorderSide.none,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? editTextRadius),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? editTextRadius),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? editTextRadius),
      borderSide: BorderSide(color: primaryColor, width: 1.0),
    ),
    fillColor: context.cardColor,
    filled: true,
  );
}

int findMiddleFactor(int n) {
  List<int?> num = [];
  for (int i = 1; i <= n; i++) {
    if (n % i == 0 && i > 1 && i < 20) {
      num.add(i);
    }
  }
  return num[num.length ~/ 2]!;
}

String getWishes() {
  if (DateTime.now().hour > 0 && DateTime.now().hour < 12) {
    return 'Good Morning';
  } else if (DateTime.now().hour >= 12 && DateTime.now().hour < 16) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}

String getPostContent(String? postContent) {
  String content = '';

  content = postContent
      .validate()
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('[embed]', '<embed>')
      .replaceAll('[/embed]', '</embed>')
      .replaceAll('[caption]', '<caption>')
      .replaceAll('[/caption]', '</caption>')
      .replaceAll('[blockquote]', '<blockquote>')
      .replaceAll('[/blockquote]', '</blockquote>');

  return content;
}

Country defaultCountry() {
  return Country(
    phoneCode: '234',
    countryCode: 'NG',
    e164Sc: 234,
    geographic: true,
    level: 1,
    name: 'Nigeria',
    example: '8142510807',
    displayName: 'Nigeria (NG) [+234]',
    displayNameNoCountryCode: 'Nigeria (NG)',
    e164Key: '234-NG-0',
    fullExampleWithPlusSign: '+2348142510807',
  );
}
