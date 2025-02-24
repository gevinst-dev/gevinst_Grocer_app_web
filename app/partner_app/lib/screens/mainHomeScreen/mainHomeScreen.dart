import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/ordersProvider.dart';
import 'package:project/screens/mainHomeScreen/productListScreen.dart';

class MainHomeScreen extends StatefulWidget {
  MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<MainHomeScreen> {
  NetworkStatus networkStatus = NetworkStatus.Online;
  int currentPage = 0;
  List lblHomeBottomMenu = [];

  //total pageListing
  List<Widget> pages = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    checkConnectionState();

    if (Constant.session.isSeller() == true) {
      pages = [
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => DashboardProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => SettingsProvider(),
            ),
          ],
          child: HomeScreen(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrdersProvider(),
          child: OrderListScreen(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductListProvider(),
          child: ProductListScreen(
            currentFilterIndex: 0,
          ),
        ),
        ProfileScreen()
      ];
    } else {
      pages = [
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => OrdersProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => DashboardProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => SettingsProvider(),
            ),
          ],
          child: HomeScreen(),
        ),
        ProfileScreen()
      ];
    }

    Future.delayed(Duration.zero).then((value) async {
      if (Constant.session.isUserLoggedIn()) {
        await getNotificationSettingsRepository(params: {}).then(
          (value) async {
            if (value[ApiAndParams.status].toString() == "1") {
              late AppNotificationSettings notificationSettings =
                  AppNotificationSettings.fromJson(value);
              if (notificationSettings.data!.isEmpty) {
                await updateNotificationSettingsRepository(
                  params: {
                    ApiAndParams.statusIds: "1,2,3,4,5,6,7,8",
                    ApiAndParams.mobileStatuses: "1,1,1,1,1,1,1,1",
                    ApiAndParams.mailStatuses: "1,1,1,1,1,1,1,1"
                  },
                );
              }
            }
          },
        );
      }
    });

    super.initState();
  }

  //internet connection checking
  checkConnectionState() async {
    networkStatus =
        await checkInternet() ? NetworkStatus.Online : NetworkStatus.Offline;
    Connectivity().onConnectivityChanged.listen((status) {
      if (mounted) {
        setState(() {
          networkStatus = getNetworkStatus(status[0]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.session.isSeller()) {
      lblHomeBottomMenu = [
        getTranslatedValue(
          context,
          "home_bottom_menu_home",
        ),
        getTranslatedValue(
          context,
          "home_bottom_menu_orders",
        ),
        getTranslatedValue(
          context,
          "home_bottom_menu_products",
        ),
        getTranslatedValue(
          context,
          "home_bottom_menu_profile",
        ),
      ];
    } else {
      lblHomeBottomMenu = [
        getTranslatedValue(
          context,
          "home_bottom_menu_home",
        ),
        getTranslatedValue(
          context,
          "home_bottom_menu_profile",
        ),
      ];
    }
    return Scaffold(
      bottomNavigationBar: homeBottomNavigation(
        context: context,
        selectBottomMenu: selectBottomMenu,
        totalPage: pages.length,
        selectedIndex: currentPage,
        lblHomeBottomMenu: lblHomeBottomMenu,
      ),
      body: networkStatus == NetworkStatus.Online
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  return;
                } else {
                  if (currentPage != 0) {
                    if (mounted) {
                      setState(() {
                        currentPage = 0;
                      });
                    }
                  } else {
                    return;
                  }
                }
              },
              child: IndexedStack(
                index: currentPage,
                children: pages,
              ),
            )
          : Center(
              child: CustomTextLabel(
                jsonKey: "check_internet",
              ),
            ),
    );
  }

  //change current screen based on bottom menu selection
  selectBottomMenu(int index) {
    if (mounted) {
      currentPage = index;
      setState(() {});
    }
  }
}
