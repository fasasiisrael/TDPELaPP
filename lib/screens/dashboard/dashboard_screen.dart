import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/screens/auth/sign_in_screen.dart';
import 'package:news_flutter/screens/category/category_list_screen.dart';
import 'package:news_flutter/screens/dashboard/components/profile_widget.dart';
import 'package:news_flutter/screens/dashboard/fragments/bookmark_fragment.dart';
import 'package:news_flutter/screens/dashboard/fragments/home_fragment.dart';
import 'package:news_flutter/utils/colors.dart';
import 'package:news_flutter/utils/constant.dart';
import 'package:news_flutter/utils/images.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../main.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int selectedIndex = 0;

  List<Widget> pages = [
    HomeFragment(),
    BookmarkFragment(isTab: true),
    CategoryListScreen(isTab: true),
    SizedBox(),
  ];

  @override
  void initState() {
    super.initState();
    bookmarkStore.getBookMarkList();
  }

  //region User Info sheet
  void profileInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProfileWidget();
      },
    );
  }
  //endregion

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String screenName = 'DashboardScreen';
    analytics.setCurrentScreen(screenName: screenName);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: pages[selectedIndex],
          bottomNavigationBar: BottomNavStyle3(
            navBarEssentials: NavBarEssentials(
              navBarHeight: 54,
              selectedIndex: selectedIndex,
              backgroundColor: context.cardColor,
              padding: NavBarPadding.all(0),
              onItemSelected: (index) {
                if (index == 3) {
                  profileInfoSheet(context);
                } else {
                  if (index == 1 && !appStore.isLoggedIn) {
                    SignInScreen().launch(context);
                  } else {
                    selectedIndex = index;
                    setState(() {});
                  }
                }
              },
              items: [
                PersistentBottomNavBarItem(
                  activeColorPrimary: primaryColor,
                  icon: Image.asset(ic_home_bold, width: 22, height: 22, color: primaryColor),
                  inactiveIcon: Image.asset(ic_home, width: 18, height: 18, color: appStore.isDarkMode ? Colors.grey.shade500 : Colors.black),
                ),
                PersistentBottomNavBarItem(
                  activeColorPrimary: primaryColor,
                  icon: Image.asset(ic_bookmark_bold, width: 22, height: 22, color: primaryColor),
                  inactiveIcon: Image.asset(ic_bookmark, width: 22, height: 22, color: appStore.isDarkMode ? Colors.grey.shade500 : Colors.black),
                ),
                PersistentBottomNavBarItem(
                  activeColorPrimary: primaryColor,
                  icon: Image.asset(ic_category_bold, width: 22, height: 22, color: primaryColor),
                  inactiveIcon: Image.asset(ic_category, width: 22, height: 22, color: appStore.isDarkMode ? Colors.grey.shade500 : Colors.black),
                ),
                PersistentBottomNavBarItem(
                  activeColorPrimary: primaryColor,
                  icon: Image.asset(ic_profile_bold, width: 22, height: 22, color: primaryColor),
                  inactiveIcon: Image.asset(ic_profile, width: 22, height: 22, color: appStore.isDarkMode ? Colors.grey.shade500 : Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
