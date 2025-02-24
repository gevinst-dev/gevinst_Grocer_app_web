import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class NotificationsAndMailSettingsScreenScreen extends StatefulWidget {
  const NotificationsAndMailSettingsScreenScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsAndMailSettingsScreenScreen> createState() =>
      _NotificationsAndMailSettingsScreenScreenState();
}

class _NotificationsAndMailSettingsScreenScreenState
    extends State<NotificationsAndMailSettingsScreenScreen> {
  List<String> lblOrderStatusDisplayNames = [];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () {
        context
            .read<NotificationsSettingsProvider>()
            .getAppNotificationSettingsApiProvider(
                params: {}, context: context);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    lblOrderStatusDisplayNames = [
      getTranslatedValue(context, "order_status_display_names_awaiting"),
      getTranslatedValue(context, "order_status_display_names_received"),
      getTranslatedValue(context, "order_status_display_names_processed"),
      getTranslatedValue(context, "order_status_display_names_shipped"),
      getTranslatedValue(
          context, "order_status_display_names_out_for_delivery"),
      getTranslatedValue(context, "order_status_display_names_delivered"),
      getTranslatedValue(context, "order_status_display_names_cancelled"),
      getTranslatedValue(context, "order_status_display_names_returned"),
    ];

    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "notifications_settings",
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          getSizedBox(height: 10),
          Consumer<NotificationsSettingsProvider>(
            builder: (context, notificationsSettingsProvider, _) {
              if (notificationsSettingsProvider.notificationsSettingsState ==
                  NotificationsSettingsState.loaded) {
                return Column(
                  children: List.generate(
                      notificationsSettingsProvider
                              .notificationSettingsDataList.length -
                          1,
                      (index) => _buildSettingItemContainer(index)),
                );
              } else if (notificationsSettingsProvider
                      .notificationsSettingsState ==
                  NotificationsSettingsState.loading) {
                return Column(
                  children:
                      List.generate(8, (index) => _buildSettingItemShimmer()),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
          Consumer<NotificationsSettingsProvider>(
            builder: (context, notificationsSettingsProvider, _) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                    start: Constant.paddingOrMargin10,
                    end: Constant.paddingOrMargin10,
                    bottom: Constant.paddingOrMargin10),
                child: gradientBtnWidget(
                  context,
                  Constant.paddingOrMargin10,
                  callback: () {
                    context
                        .read<NotificationsSettingsProvider>()
                        .updateAppNotificationSettingsApiProvider(
                            context: context);
                  },
                  otherWidgets: notificationsSettingsProvider
                              .notificationsSettingsUpdateState ==
                          NotificationsSettingsUpdateState.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: ColorsRes.appColorWhite,
                          ),
                        )
                      : CustomTextLabel(
                          jsonKey: "update_settings",
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleMedium!.merge(
                                TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500),
                              ),
                        ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  _buildSettingItemContainer(int index) {
    return Consumer<NotificationsSettingsProvider>(
      builder: (context, notificationsSettingsProvider, _) {
        AppNotificationSettingsData notificationSettingsData =
            notificationsSettingsProvider.notificationSettingsDataList[index];
        return Card(
          color: Theme.of(context).cardColor,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsetsDirectional.only(
              start: Constant.paddingOrMargin10,
              end: Constant.paddingOrMargin10,
              bottom: Constant.paddingOrMargin10),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                start: Constant.paddingOrMargin10,
                end: Constant.paddingOrMargin10,
                top: Constant.paddingOrMargin5,
                bottom: Constant.paddingOrMargin5),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextLabel(
                    text: lblOrderStatusDisplayNames[int.parse(
                            notificationSettingsData.orderStatusId ?? "0")]
                        .toString(),
                  ),
                ),
                Column(
                  children: [
                    CustomTextLabel(
                      jsonKey: "mail",
                    ),
                    Switch(
                      value:
                          notificationsSettingsProvider.mailSettings[index] ==
                              1,
                      onChanged: (value) {
                        notificationsSettingsProvider.changeMailSetting(
                            index: index, status: value == true ? 1 : 0);
                      },
                      activeColor: ColorsRes.appColor,
                      inactiveTrackColor: ColorsRes.subTitleTextColor,
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomTextLabel(
                      jsonKey: "mobile",
                    ),
                    Switch(
                      value:
                          notificationsSettingsProvider.mobileSettings[index] ==
                              1,
                      onChanged: (value) {
                        notificationsSettingsProvider.changeMobileSetting(
                            index: index, status: value == true ? 1 : 0);
                      },
                      activeColor: ColorsRes.appColor,
                      inactiveTrackColor: ColorsRes.subTitleTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildSettingItemShimmer() {
    return CustomShimmer(
      width: MediaQuery.sizeOf(context).width,
      height: 80,
      borderRadius: 5,
      margin: EdgeInsetsDirectional.only(
          start: Constant.paddingOrMargin10,
          end: Constant.paddingOrMargin10,
          bottom: Constant.paddingOrMargin10),
    );
  }
}
