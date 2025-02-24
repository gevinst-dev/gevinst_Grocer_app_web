import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> profileMenus = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () {
        setProfileMenuList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    setProfileMenuList();

    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "title_profile",
          softWrap: true,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            profileHeader(
              context: context,
              name: Constant.session.getData(SessionManager.name),
              mobile: Constant.session.getData(SessionManager.mobile),
            ),
            SizedBox(height: 1),
            Flexible(
              child: Card(
                color: Theme.of(context).cardColor,
                surfaceTintColor: Colors.transparent,
                child: profileMenuWidget(profileMenus: profileMenus),
              ),
            )
          ],
        ),
      ),
    );
  }

  setProfileMenuList() {
    profileMenus = [];
    profileMenus = [
      {
        "icon": "theme_icon",
        "label": getTranslatedValue(context, "change_theme"),
        "clickFunction": themeDialog,
      },
      if (context.read<LanguageProvider>().languages.length > 1)
        {
          "icon": "translate_icon",
          "label": getTranslatedValue(context, "change_language"),
          "clickFunction": (context) {
            showModalBottomSheet<void>(
              backgroundColor: Theme.of(context).cardColor,
              context: context,
              isScrollControlled: true,
              shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
              builder: (BuildContext context) {
                return Wrap(
                  children: [
                    BottomSheetLanguageListContainer(),
                  ],
                );
              },
            );
          },
          "isResetLabel": true,
        },
      /*
        {
          "icon": "notification_icon",
          "label": getTranslatedValue(context,"lblNotification,
          "clickFunction": (context) {
            Navigator.pushNamed(context, notificationListScreen);
          },
          "isResetLabel": false
        },

        {
          "icon": "transaction_icon",
          "label": getTranslatedValue(context,"lblTransactionHistory,
          "clickFunction": (context) {
            Navigator.pushNamed(context, transactionListScreen);
          },
          "isResetLabel": false
        },*/
      if (Constant.session.isSeller())
        {
          "icon": "category_icon",
          "label": getTranslatedValue(context, "title_categories"),
          "clickFunction": (context) {
            Navigator.pushNamed(context, categoryListScreen, arguments: "");
          },
          "isResetLabel": false
        },
      if (Constant.session.isSeller())
        {
          "icon": "products_icon",
          "label": getTranslatedValue(context, "title_products"),
          "clickFunction": (context) {
            Navigator.pushNamed(context, productListScreen, arguments: 0);
          },
          "isResetLabel": false
        },
      if (Constant.session.isSeller())
        {
          "icon": "sold_out_products",
          "label": getTranslatedValue(context, "title_stock_management"),
          "clickFunction": (context) {
            Navigator.pushNamed(context, productStockManagementScreen);
          },
          "isResetLabel": false
        },
      if (Constant.session.isSeller())
        {
          "icon": "products_bulk_upload_icon",
          "label": getTranslatedValue(context, "title_products_bulk_upload"),
          "clickFunction": (context) {
            Navigator.pushNamed(context, productBulkOperationScreen,
                arguments: "upload");
          },
          "isResetLabel": false
        },
      if (Constant.session.isSeller())
        {
          "icon": "products_bulk_update_icon",
          "label": getTranslatedValue(context, "title_products_bulk_update"),
          "clickFunction": (context) {
            Navigator.pushNamed(context, productBulkOperationScreen,
                arguments: "update");
          },
          "isResetLabel": false
        },
      // {
      //   "icon": "settings",
      //   "label": getTranslatedValue(context, "notifications_settings"),
      //   "clickFunction": (context) {
      //     Navigator.pushNamed(
      //         context, notificationsAndMailSettingsScreenScreen);
      //   },
      //   "isResetLabel": false
      // },
      if (Constant.session.isUserLoggedIn() &&
          Constant.session.isSeller() == true)
        {
          "icon": "wallet_history_icon",
          "label": getTranslatedValue(context, "wallet_history"),
          "clickFunction": (context) {
            Navigator.pushNamed(context, walletHistoryListScreen);
          },
          "isResetLabel": false
        },
      {
        "icon": "withdrawal_requests",
        "label": getTranslatedValue(context, "withdrawal_requests"),
        "clickFunction": (context) {
          Navigator.pushNamed(context, withdrawalRequestsListScreen);
        },
        "isResetLabel": false
      },
      {
        "icon": "rate_icon",
        "label": getTranslatedValue(context, "rate_us"),
        "clickFunction": (BuildContext context) {
          launchUrl(
              Uri.parse(Platform.isAndroid
                  ? Constant.playStoreUrl
                  : Constant.appStoreUrl),
              mode: LaunchMode.externalApplication);
        },
      },
/*      {
        "icon": "share_icon",
        "label": getTranslatedValue(context,"lblShareApp,
        "clickFunction": (BuildContext context) {
          String shareAppMessage = getTranslatedValue(context,"lblShareAppMessage;
          if (Platform.isAndroid) {
            shareAppMessage = "$shareAppMessage${Constant.playStoreUrl}";
          } else if (Platform.isIOS) {
            shareAppMessage = "$shareAppMessage${Constant.appStoreUrl}";
          }
          Share.share(shareAppMessage, subject: "Share app");
        },
      }*/
      {
        "icon": "terms_icon",
        "label": getTranslatedValue(context, "terms_of_service"),
        "clickFunction": (context) {
          Navigator.pushNamed(
            context,
            webViewScreen,
            arguments: getTranslatedValue(context, "terms_of_service"),
          );
        }
      },
      {
        "icon": "privacy_icon",
        "label": getTranslatedValue(context, "privacy_policy"),
        "clickFunction": (context) {
          Navigator.pushNamed(
            context,
            webViewScreen,
            arguments: getTranslatedValue(context, "privacy_policy"),
          );
        }
      },
      {
        "icon": "logout_icon",
        "label": getTranslatedValue(context, "logout"),
        "clickFunction": Constant.session.logoutUser,
        "isResetLabel": false
      },
      {
        "icon": "delete_user_account_icon",
        "label": getTranslatedValue(context, "delete_user_account"),
        "clickFunction": (context) {
          showDialog<String>(
            context: context,
            builder: (BuildContext buildContext) => AlertDialog(
              backgroundColor: Theme.of(buildContext).cardColor,
              surfaceTintColor: Colors.transparent,
              title: CustomTextLabel(
                jsonKey: "delete_user_account",
                softWrap: true,
              ),
              content: CustomTextLabel(
                jsonKey: "delete_user_message",
                softWrap: true,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(buildContext),
                  child: CustomTextLabel(
                    jsonKey: "cancel",
                    softWrap: true,
                    style: TextStyle(color: ColorsRes.subTitleTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    deleteUserAccount(params: {}).then((value) {
                      if (value[ApiAndParams.status].toString() == "1") {
                        showMessage(context, value[ApiAndParams.message],
                            MessageType.warning);
                        Navigator.pop(context);
                        Constant.session.processToLogout(buildContext);
                      }
                    });
                  },
                  child: CustomTextLabel(
                    jsonKey: "ok",
                    softWrap: true,
                    style: TextStyle(color: ColorsRes.appColor),
                  ),
                ),
              ],
            ),
          );
        },
        "isResetLabel": false
      },
    ];

    setState(() {});
  }
}
