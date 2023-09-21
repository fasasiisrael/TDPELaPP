import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/app_widgets.dart';
import 'package:news_flutter/components/back_widget.dart';
import 'package:news_flutter/configs.dart';
import 'package:news_flutter/model/weather_model.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';

import '../../main.dart';

class WeatherViewScreen extends StatefulWidget {
  final WeatherModel weatherModel;

  WeatherViewScreen(this.weatherModel);

  @override
  WeatherViewScreenState createState() => WeatherViewScreenState();
}

class WeatherViewScreenState extends State<WeatherViewScreen> {
  int dayWeather = 0;
  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    myBanner = buildBannerAd()..load();
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: BANNER_AD_ID_FOR_ANDROID,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          //
        },
      ),
      request: AdRequest(),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    myBanner?.dispose();
    super.dispose();
  }

  Color getColor(int count) {
    if (count >= 0 && count <= 50) {
      return Color(0xFF34A12B);
    } else if (count > 50 && count <= 100) {
      return Color(0xFFD4CC0F);
    } else if (count > 100 && count <= 200) {
      return Color(0xFFE9572A);
    } else if (count > 200 && count <= 300) {
      return Color(0xFFEC4D9F);
    } else if (count > 300 && count <= 400) {
      return Color(0xFF9858A2);
    } else {
      return Color(0xFFC11E2F);
    }
  }

  Widget airQualityData(String image, int data, {double width = 35, double height = 35}) {
    return SizedBox(
      width: context.width() / 3 - 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cachedImage(image, height: height, width: width, color: context.iconColor),
          8.height,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$data', style: boldTextStyle()),
              4.width,
              Text('μg/m3', style: secondaryTextStyle(size: 14, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    ).paddingAll(8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: context.statusBarHeight),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackWidget(color: context.iconColor),
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: appStore.isDarkMode ? context.cardColor : Colors.grey.shade100, borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              cachedImage('https:${widget.weatherModel.current!.condition!.icon.validate().replaceAll('64x64', '128x128')}', width: 100, height: 100),
                              16.width,
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${widget.weatherModel.current!.feelslike_c.validate().round()}°C', style: boldTextStyle(size: 42)).paddingLeft(8),
                                  Text('${widget.weatherModel.location!.name.validate()}', style: secondaryTextStyle(size: 16)).paddingLeft(8),
                                ],
                              ),
                            ],
                          ),
                        ),
                        8.height,
                        Divider(thickness: 0.1, color: Colors.grey.shade400),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(8), backgroundColor: appStore.isDarkMode ? appBackGroundColor : white),
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  cachedImage(wind_fan, width: 80),
                                  8.height,
                                  Text('${widget.weatherModel.current!.wind_kph.validate()}km/h', style: primaryTextStyle(color: textBlueColor)),
                                  Text(language.windSpeed, style: secondaryTextStyle()),
                                ],
                              ),
                            ),
                            16.width,
                            Column(
                              children: [
                                cachedImage(ic_sun_rise_set, width: 150),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${widget.weatherModel.forecast!.forecastday![0].astro!.sunrise.validate()}',
                                          style: primaryTextStyle(color: textBlueColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          language.sunrise,
                                          style: secondaryTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ).paddingLeft(8).expand(),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${widget.weatherModel.forecast!.forecastday![0].astro!.sunset.validate()}',
                                          style: primaryTextStyle(color: textBlueColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          language.sunset,
                                          style: secondaryTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ).paddingRight(8).expand(),
                                  ],
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  !isAdsDisabled && myBanner != null
                      ? Container(
                          color: context.scaffoldBackgroundColor,
                          height: 60,
                          child: myBanner != null ? AdWidget(ad: myBanner!) : SizedBox(),
                        ).paddingSymmetric(vertical: 16)
                      : SizedBox(),
                  Divider(color: Colors.grey.shade200),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.thisWeek, style: boldTextStyle(size: 20)).paddingSymmetric(horizontal: 16, vertical: 8),
                      HorizontalList(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: widget.weatherModel.forecast!.forecastday.validate().length,
                        itemBuilder: (context, index) {
                          Day day = widget.weatherModel.forecast!.forecastday.validate()[index].day!;

                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                                color: dayWeather == index
                                    ? context.cardColor
                                    : appStore.isDarkMode
                                        ? card_color_dark
                                        : white,
                                borderRadius: BorderRadius.circular(defaultRadius)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${DateFormat.MMMd().format(DateFormat('yyyy-MM-dd').parse(widget.weatherModel.forecast!.forecastday.validate()[index].date.validate()))}',
                                  style: secondaryTextStyle(size: 16),
                                ),
                                cachedImage('https:${day.condition!.icon.validate()}'),
                                Text('${day.maxtemp_c}° ${day.mintemp_c}°', style: boldTextStyle(size: 14)),
                              ],
                            ),
                          ).onTap(
                            () {
                              dayWeather = index;
                              setState(() {});
                            },
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ).paddingRight(8);
                        },
                      ),
                    ],
                  ),
                  20.height,
                ],
              ),
              Divider(color: Colors.grey.shade200),
              Stack(
                children: [
                  Positioned(bottom: 0, child: cachedImage(ic_wave, width: context.width(), color: primaryColor)),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(language.majorAirPollutant, style: boldTextStyle(size: 20)),
                      ).paddingOnly(top: 8, bottom: 8),
                      Wrap(
                        children: [
                          airQualityData(ic_pm2, widget.weatherModel.current!.air_quality!.pm2_5!.round()),
                          airQualityData(ic_pm10, widget.weatherModel.current!.air_quality!.pm10!.round()),
                          airQualityData(ic_so2, widget.weatherModel.current!.air_quality!.so2!.round()),
                          airQualityData(ic_co, widget.weatherModel.current!.air_quality!.co!.round()),
                          airQualityData(ic_o3, widget.weatherModel.current!.air_quality!.o3!.round(), width: 40),
                          airQualityData(ic_no2, widget.weatherModel.current!.air_quality!.no2!.round(), width: 40),
                        ],
                      ).paddingAll(8),
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
