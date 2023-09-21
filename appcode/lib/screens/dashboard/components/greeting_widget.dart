import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/model/weather_model.dart';
import 'package:news_flutter/network/rest_apis.dart';
import 'package:news_flutter/screens/notifications/notification_list_screen.dart';
import 'package:news_flutter/screens/dashboard/search_fragment.dart';
import 'package:news_flutter/screens/dashboard/weather_view_screen.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/common.dart';
import 'package:news_flutter/utils/images.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/main.dart';

class GreetingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherModel>(
      future: AsyncMemoizer<WeatherModel>().runOnce(() => weatherApi()),
      builder: (context, snap) {
        if (snap.hasData) {
          WeatherModel model = snap.data!;

          return Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(32)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cachedImage('https:${model.current!.condition!.icon.validate()}', width: 30, height: 30),
                    4.width,
                    Text('${model.current!.feelslike_c.validate().round()}°C', style: boldTextStyle()).paddingRight(8),
                  ],
                ),
              ).onTap(() async {
                WeatherViewScreen(model).launch(context);
              }),
              8.width,
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(28)),
                child: Row(
                  children: [
                    cachedImage(ic_search, width: 22, color: Colors.grey.withOpacity(0.8)).paddingRight(8),
                    Text(language.search, style: secondaryTextStyle(size: 16), overflow: TextOverflow.ellipsis, maxLines: 1).expand(),
                  ],
                ),
              ).onTap(
                    () {
                  SearchFragment().launch(
                    context,
                    pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
                    duration: Duration(milliseconds: 500),
                  );
                },
              ).expand(),
              IconButton(
                icon: cachedImage(ic_notification, width: 22, height: 22, color: appStore.isDarkMode ? Colors.white : Colors.black),
                onPressed: () {
                  NotificationListScreen().launch(context);
                },
              ),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            cachedImage('assets/news/gif/ic_hand_wave.gif', width: 50, height: 50),
            Text(getWishes(), style: boldTextStyle(size: 20)),
          ],
        ).paddingAll(8);
      },
    );
  }
}
