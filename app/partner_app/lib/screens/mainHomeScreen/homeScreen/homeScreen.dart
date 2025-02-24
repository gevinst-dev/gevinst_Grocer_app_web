import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/sellerDashBoard.dart';
import 'package:project/provider/ordersProvider.dart';
import 'package:project/provider/ordersStatusUpdateProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController scrollController = ScrollController()
    ..addListener(activeOrdersScrollListener);

  List lblOrderStatusDisplayNames = [];
  List lblOrderStatusUpdateNames = [];

  String startDate = "";
  String endDate = "";

  void activeOrdersScrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<OrdersProvider>().hasMoreData) {
          callApi();
        }
      }
    }
  }

  Future callApi({bool? reset}) async {
    if (reset == true) {
      resetDate();
      context.read<OrdersProvider>().offset = 0;
      context.read<OrdersProvider>().sellerOrdersList.clear();
      context.read<OrdersProvider>().deliveryBoyOrdersList.clear();
    }

    Map<String, String> params = {};
    if (isDateRangeValidate()) {
      params[ApiAndParams.startDeliveryDate] = startDate;
      params[ApiAndParams.endDeliveryDate] = endDate;
    }

    await context
        .read<OrdersProvider>()
        .getOrders(context: context, params: params);
  }

  bool isDateRangeValidate() {
    return (startDate != getTranslatedValue(context, "start_date") &&
        endDate != getTranslatedValue(context, "end_date"));
  }

  resetDate() {
    startDate = getTranslatedValue(context, "start_date");
    endDate = getTranslatedValue(context, "end_date");
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      context.read<SettingsProvider>().getSettingsApiProvider({}, context).then(
        (value) {
          lblOrderStatusDisplayNames = [
            getTranslatedValue(context, "order_status_display_names_all"),
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

          lblOrderStatusUpdateNames = [
            getTranslatedValue(context, "order_status_display_names_awaiting"),
            getTranslatedValue(context, "order_status_display_names_received"),
            getTranslatedValue(context, "order_status_display_names_processed"),
            getTranslatedValue(context, "order_status_display_names_shipped"),
            getTranslatedValue(
                context, "order_status_display_names_out_for_delivery"),
            getTranslatedValue(context, "order_status_display_names_delivered"),
          ];

          if (Constant.appMaintenanceMode != "1") {
            context
                .read<DashboardProvider>()
                .dashboardApiProvider({}, context).then((value) {
              if (!Constant.session.isSeller()) {
                callApi(reset: true);
              }
            });
          } else {
            Navigator.pushReplacementNamed(context, underMaintenanceScreen);
          }
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            text: "Home",
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
          centerTitle: true),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          if (Constant.session.isSeller()) {
            List<CategoryProductCount> categoryProductCounts = [];
            try {
              categoryProductCounts = dashboardProvider
                      .sellerDashBoard.data?.categoryProductCount ??
                  [];
            } catch (_) {}
            return dashboardProvider.dashboardState == DashboardState.loaded
                ? setRefreshIndicator(
                    refreshCallback: () async {
                      await context
                          .read<DashboardProvider>()
                          .dashboardApiProvider({}, context);
                    },
                    child: ListView(
                      children: [
                        GridView.count(
                          childAspectRatio: 1,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          crossAxisCount: 2,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsetsDirectional.all(10),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            getStatisticsContainer(
                              context: context,
                              bgColor: ColorsRes.sellerStatisticsColors[0],
                              svgIconName: "orders",
                              title: getTranslatedValue(context, "orders"),
                              itemCount: dashboardProvider
                                      .sellerDashBoard.data?.sellerOrderCount
                                      .toString() ??
                                  "0",
                            ),
                            getStatisticsContainer(
                              context: context,
                              bgColor: ColorsRes.sellerStatisticsColors[1],
                              svgIconName: "products",
                              title: getTranslatedValue(context, "products"),
                              itemCount: dashboardProvider
                                      .sellerDashBoard.data?.productCount
                                      .toString() ??
                                  "0",
                            ),
                            getStatisticsContainer(
                              svgIconName: "sold_out_products",
                              bgColor: ColorsRes.sellerStatisticsColors[2],
                              context: context,
                              title: getTranslatedValue(
                                  context, "sold_out_products"),
                              itemCount: dashboardProvider
                                      .sellerDashBoard.data?.soldOutCount
                                      .toString() ??
                                  "0",
                              voidCallback: () {
                                Navigator.pushNamed(
                                  context,
                                  productListScreen,
                                  arguments: 2,
                                );
                              },
                            ),
                            getStatisticsContainer(
                              svgIconName: "low_stock_products",
                              bgColor: ColorsRes.sellerStatisticsColors[3],
                              context: context,
                              title: getTranslatedValue(
                                  context, "low_stock_products"),
                              itemCount: dashboardProvider
                                      .sellerDashBoard.data?.lowStockCount
                                      .toString() ??
                                  "0",
                              voidCallback: () {
                                Navigator.pushNamed(
                                  context,
                                  productListScreen,
                                  arguments: 1,
                                );
                              },
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: WeeklySalesBarChart(
                              weeklySales: dashboardProvider
                                      .sellerDashBoard.data?.weeklySales ??
                                  [],
                              maxSaleLimit: dashboardProvider.maxSaleLimit),
                        ),
                        if (categoryProductCounts.length > 0)
                          Container(
                            height: MediaQuery.sizeOf(context).height * 0.30,
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CategoryPieChart(
                              categoryProductCounts: categoryProductCounts,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      GridView.count(
                        childAspectRatio: 1,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        crossAxisCount: 2,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.all(10),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          CustomShimmer(
                              width: double.maxFinite,
                              borderRadius: 10,
                              height: 150),
                          CustomShimmer(
                              width: double.maxFinite,
                              borderRadius: 10,
                              height: 150),
                          CustomShimmer(
                              width: double.maxFinite,
                              borderRadius: 10,
                              height: 150),
                          CustomShimmer(
                              width: double.maxFinite,
                              borderRadius: 10,
                              height: 150),
                        ],
                      ),
                      CustomShimmer(
                        width: double.maxFinite,
                        borderRadius: 10,
                        height: 300,
                        margin: EdgeInsetsDirectional.only(
                          start: 10,
                          end: 10,
                        ),
                      ),
                      CustomShimmer(
                        width: double.maxFinite,
                        borderRadius: 10,
                        height: 150,
                        margin: EdgeInsetsDirectional.all(10),
                      ),
                    ],
                  );
          } else if (dashboardProvider.dashboardState ==
              DashboardState.loaded) {
            return setRefreshIndicator(
              refreshCallback: () async {
                await context
                    .read<DashboardProvider>()
                    .dashboardApiProvider({}, context);
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    GridView.count(
                      childAspectRatio: 1,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 2,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsetsDirectional.all(10),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        getStatisticsContainer(
                          context: context,
                          bgColor: ColorsRes.sellerStatisticsColors[0],
                          svgIconName: "orders",
                          title: getTranslatedValue(context, "orders"),
                          itemCount: dashboardProvider
                                  .deliveryBashBoard.data?.orderCount
                                  .toString() ??
                              "0",
                        ),
                        getStatisticsContainer(
                          context: context,
                          svgIconName: "balance",
                          bgColor: ColorsRes.sellerStatisticsColors[1],
                          title: getTranslatedValue(context, "balance"),
                          itemCount: dashboardProvider
                                  .deliveryBashBoard.data?.balance
                                  .toString() ??
                              "0",
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            lblOrderStatusDisplayNames.length, (statusIndex) {
                          return GestureDetector(
                            onTap: () async {
                              if (mounted) {
                                await context
                                    .read<OrdersProvider>()
                                    .changeOrderSelectedStatus(statusIndex)
                                    .then((value) async {
                                  if (value) {
                                    callApi();
                                  }
                                });
                              }
                            },
                            child: getOrderStatusContainer(
                                isActive: context
                                        .watch<OrdersProvider>()
                                        .selectedStatus ==
                                    statusIndex,
                                svgIconName:
                                    Constant.orderStatusIcons[statusIndex],
                                context: context,
                                title: lblOrderStatusDisplayNames[statusIndex]
                                    .toString()),
                          );
                        }),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 10,
                        end: 10,
                      ),
                      child: Container(
                        padding: EdgeInsetsDirectional.all(
                            (!isDateRangeValidate()) ? 12 : 14),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: ColorsRes.subTitleTextColor),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomTextLabel(
                                text:
                                    "$startDate\t\t${getTranslatedValue(context, "to")}\t\t$endDate",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            getSizedBox(width: 10),
                            if (!isDateRangeValidate())
                              GestureDetector(
                                onTap: () {
                                  showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(
                                        DateTime.now().year - 100, 1, 1),
                                    lastDate: DateTime.now(),
                                    currentDate: DateTime.now(),
                                    keyboardType: TextInputType.datetime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Constant.session.getBoolData(
                                                SessionManager.isDarkTheme)
                                            ? ThemeData.dark().copyWith(
                                                colorScheme: ColorScheme.dark(
                                                  primary: ColorsRes.appColor,
                                                  onPrimary:
                                                      ColorsRes.mainTextColor,
                                                  surface: Theme.of(context)
                                                      .cardColor,
                                                  inverseSurface: ColorsRes
                                                      .subTitleTextColor,
                                                  onSurface:
                                                      ColorsRes.mainTextColor,
                                                  secondary: ColorsRes.appColor,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                dialogBackgroundColor:
                                                    Theme.of(context).cardColor,
                                              )
                                            : ThemeData.light().copyWith(
                                                colorScheme: ColorScheme.dark(
                                                  primary: ColorsRes.appColor,
                                                  onPrimary:
                                                      ColorsRes.mainTextColor,
                                                  surface: Theme.of(context)
                                                      .cardColor,
                                                  onSurface:
                                                      ColorsRes.mainTextColor,
                                                  inverseSurface: ColorsRes
                                                      .subTitleTextColor,
                                                  secondary: ColorsRes.appColor,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                dialogBackgroundColor:
                                                    Theme.of(context).cardColor,
                                              ),
                                        child: child!,
                                      );
                                    },
                                  ).then(
                                    (value) {
                                      if (value != null) {
                                        startDate = value.start
                                            .toString()
                                            .split(" ")[0];
                                        endDate =
                                            value.end.toString().split(" ")[0];

                                        context.read<OrdersProvider>().offset =
                                            0;
                                        context
                                            .read<OrdersProvider>()
                                            .sellerOrdersList
                                            .clear();
                                        context
                                            .read<OrdersProvider>()
                                            .deliveryBoyOrdersList
                                            .clear();

                                        setState(() {});
                                        callApi();
                                      }
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: ColorsRes.mainTextColor,
                                ),
                              ),
                            if (isDateRangeValidate())
                              GestureDetector(
                                onTap: () {
                                  callApi(reset: true);
                                  setState(() {});
                                },
                                child: CustomTextLabel(
                                  jsonKey: "clear",
                                  style: TextStyle(
                                    color: ColorsRes.appColorRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    getSizedBox(height: 10),
                    Consumer<OrdersProvider>(
                      builder: (context, ordersProvider, child) {
                        if (ordersProvider.ordersState == OrdersState.loaded ||
                            ordersProvider.ordersState ==
                                OrdersState.loadingMore ||
                            ordersProvider.ordersState ==
                                OrdersState.silentLoading) {
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  ordersProvider.deliveryBoyOrdersList.length,
                              itemBuilder: (context, index) {
                                if (index ==
                                    ordersProvider
                                            .deliveryBoyOrdersList.length -
                                        1) {
                                  if (ordersProvider.ordersState ==
                                      OrdersState.loadingMore) {
                                    return _buildOrderContainerShimmer();
                                  }
                                }
                                return _buildOrderContainer(
                                    ordersProvider.deliveryBoyOrdersList[index],
                                    index.toString());
                              });
                        } else if (ordersProvider.ordersState ==
                                OrdersState.loaded ||
                            ordersProvider.ordersState == OrdersState.loading) {
                          return Column(
                            children: List.generate(
                              20,
                              (index) => _buildOrderContainerShimmer(),
                            ),
                          );
                        } else if (ordersProvider.ordersState ==
                            OrdersState.empty) {
                          return Container(
                            width: context.width,
                            child: DefaultBlankItemMessageScreen(
                              image: "no_order_icon",
                              title: "empty_orders_message",
                              description: "empty_orders_description",
                              buttonTitle: "refresh",
                              callback: () async {
                                return callApi();
                              },
                            ),
                          );
                        } else {
                          return Container(
                            width: context.width,
                            child: DefaultBlankItemMessageScreen(
                              image: "something_went_wrong",
                              title: "something_went_wrong_message_title",
                              description:
                                  "something_went_wrong_message_description",
                              buttonTitle: "try_again",
                              callback: () async {
                                return callApi(reset: true);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ListView(
              children: [
                GridView.count(
                  childAspectRatio: 1,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.all(10),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    CustomShimmer(
                        width: double.maxFinite, borderRadius: 10, height: 150),
                    CustomShimmer(
                        width: double.maxFinite, borderRadius: 10, height: 150),
                    CustomShimmer(
                        width: double.maxFinite, borderRadius: 10, height: 150),
                    CustomShimmer(
                        width: double.maxFinite, borderRadius: 10, height: 150),
                  ],
                ),
                CustomShimmer(
                  width: double.maxFinite,
                  borderRadius: 10,
                  height: 300,
                  margin: EdgeInsetsDirectional.only(
                    start: 10,
                    end: 10,
                  ),
                ),
                CustomShimmer(
                  width: double.maxFinite,
                  borderRadius: 10,
                  height: 150,
                  margin: EdgeInsetsDirectional.all(10),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderContainer(DeliveryBoyOrdersListItem order, String index) {
    lblOrderStatusDisplayNames = [
      getTranslatedValue(context, "order_status_display_names_all"),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          orderDetail,
          arguments: order.orderId.toString(),
        );
      },
      child: Container(
        padding: EdgeInsets.all(Constant.paddingOrMargin10),
        margin: EdgeInsetsDirectional.only(
            start: Constant.paddingOrMargin10,
            bottom: Constant.paddingOrMargin10,
            end: Constant.paddingOrMargin10),
        decoration: DesignConfig.boxDecoration(
          Theme.of(context).cardColor,
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextLabel(
                    text: "ID #${order.id}",
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: ColorsRes.mainTextColor,
                    ),
                  ),
                ),
                getSizedBox(width: 10),
                CustomTextLabel(
                  text: getCurrencyFormat(
                    double.parse(
                      order.finalTotal.toString(),
                    ),
                  ),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: ColorsRes.appColor),
                  softWrap: true,
                ),
                if (order.orderNote.toString().isNotEmpty)
                  getSizedBox(width: 10),
                if (order.orderNote.toString().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext buildContext) => AlertDialog(
                          backgroundColor: Colors.yellow.shade200,
                          surfaceTintColor: Colors.transparent,
                          title: CustomTextLabel(
                            jsonKey: "order_note",
                            softWrap: true,
                            style: TextStyle(
                              color: ColorsRes.lightThemeTextColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          content: CustomTextLabel(
                            text: order.orderNote.toString(),
                            softWrap: true,
                            style: TextStyle(
                              color: ColorsRes.lightThemeTextColor,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(buildContext);
                              },
                              child: CustomTextLabel(
                                jsonKey: "got_it",
                                softWrap: true,
                                style: TextStyle(
                                  color: ColorsRes.appColorRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: defaultImg(
                        image: "ic_order_note",
                        width: 20,
                        height: 20,
                        iconColor: ColorsRes.appColorRed),
                  ),
              ],
            ),
            getSizedBox(
              height: 7,
            ),
            Divider(height: 1, color: ColorsRes.grey, thickness: 0),
            getSizedBox(
              height: 7,
            ),
            CustomTextLabel(
              jsonKey: "payment_method",
              style: TextStyle(fontSize: 14, color: ColorsRes.grey),
              softWrap: true,
            ),
            getSizedBox(height: 2),
            CustomTextLabel(
              text: "${order.paymentMethod}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorsRes.mainTextColor,
              ),
              softWrap: true,
            ),
            getSizedBox(height: 10),
            CustomTextLabel(
              jsonKey: "delivery_time",
              style: TextStyle(fontSize: 14, color: ColorsRes.grey),
              softWrap: true,
            ),
            getSizedBox(height: 2),
            CustomTextLabel(
              text: "${order.deliveryTime ?? ""}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorsRes.mainTextColor,
              ),
              softWrap: true,
            ),
            getSizedBox(
              height: 10,
            ),
            Divider(height: 1, color: ColorsRes.grey, thickness: 0),
            getSizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        backgroundColor: Theme.of(context).cardColor,
                        context: context,
                        isScrollControlled: true,
                        shape: DesignConfig.setRoundedBorderSpecific(20,
                            istop: true),
                        builder: (BuildContext context) {
                          return ChangeNotifierProvider(
                              create: (context) => OrderUpdateStatusProvider(),
                              builder: (context, value) {
                                return Consumer<OrderUpdateStatusProvider>(
                                  builder: (context, ordersProvider, child) {
                                    if (context
                                            .read<OrderUpdateStatusProvider>()
                                            .ordersStatusState ==
                                        OrderUpdateStatusState.initial) {
                                      context
                                          .read<OrderUpdateStatusProvider>()
                                          .setSelectedStatus(
                                            (int.parse(order.activeStatus
                                                        .toString()) -
                                                    1)
                                                .toString(),
                                          );
                                      context
                                          .read<OrderUpdateStatusProvider>()
                                          .getOrdersStatuses(context: context);
                                    }

                                    return Container(
                                      padding: EdgeInsetsDirectional.only(
                                        start: Constant.paddingOrMargin15,
                                        end: Constant.paddingOrMargin15,
                                        top: Constant.paddingOrMargin15,
                                        bottom: Constant.paddingOrMargin15,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: CustomTextLabel(
                                              jsonKey: "update_order_status",
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .merge(
                                                    TextStyle(
                                                      letterSpacing: 0.5,
                                                      color: ColorsRes
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          getSizedBox(
                                            height: 10,
                                          ),
                                          if (ordersProvider
                                                      .ordersStatusState ==
                                                  OrderUpdateStatusState
                                                      .loaded ||
                                              ordersProvider
                                                      .ordersStatusState ==
                                                  OrderUpdateStatusState
                                                      .updating)
                                            Column(
                                              children: List.generate(
                                                  ordersProvider
                                                          .orderStatusesList
                                                          .length -
                                                      2, (index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    ordersProvider
                                                        .setSelectedStatus(
                                                            index.toString());
                                                  },
                                                  child: Container(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsetsDirectional.only(
                                                                start: Constant
                                                                    .paddingOrMargin10),
                                                            child:
                                                                CustomTextLabel(
                                                              jsonKey:
                                                                  lblOrderStatusUpdateNames[
                                                                      index],
                                                            ),
                                                          ),
                                                        ),
                                                        Radio(
                                                          activeColor: ColorsRes
                                                              .appColor,
                                                          value: ordersProvider
                                                              .selectedOrderStatus,
                                                          groupValue: context
                                                              .watch<
                                                                  OrderUpdateStatusProvider>()
                                                              .orderStatusesList[
                                                                  index]
                                                              .id,
                                                          onChanged: (value) {
                                                            ordersProvider
                                                                .setSelectedStatus(
                                                                    index
                                                                        .toString());
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          getSizedBox(
                                            height: 10,
                                          ),
                                          if (ordersProvider
                                                  .ordersStatusState ==
                                              OrderUpdateStatusState.loading)
                                            Column(
                                              children:
                                                  List.generate(8, (index) {
                                                return CustomShimmer(
                                                  height: 26,
                                                  width: double.maxFinite,
                                                  margin:
                                                      EdgeInsetsDirectional.all(
                                                          10),
                                                );
                                              }),
                                            ),
                                          if (ordersProvider
                                                      .ordersStatusState ==
                                                  OrderUpdateStatusState
                                                      .loaded ||
                                              ordersProvider
                                                      .ordersStatusState ==
                                                  OrderUpdateStatusState
                                                      .updating)
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: Constant
                                                      .paddingOrMargin10),
                                              child: gradientBtnWidget(
                                                context,
                                                10,
                                                callback: () {
                                                  Map<String, String> params =
                                                      {};
                                                  params[ApiAndParams.orderId] =
                                                      order.orderId.toString();
                                                  params[ApiAndParams
                                                          .statusId] =
                                                      ordersProvider
                                                          .selectedOrderStatus
                                                          .toString();
                                                  ordersProvider
                                                      .updateOrdersStatus(
                                                        params: params,
                                                        context: context,
                                                      )
                                                      .then(
                                                        (value) =>
                                                            Navigator.pop(
                                                                context, value),
                                                      );
                                                },
                                                otherWidgets: Container(
                                                  child: (ordersProvider
                                                              .ordersStatusState ==
                                                          OrderUpdateStatusState
                                                              .loaded)
                                                      ? CustomTextLabel(
                                                          jsonKey:
                                                              "update_order_status",
                                                          softWrap: true,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .merge(
                                                                    TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                        )
                                                      : CircularProgressIndicator(
                                                          color: ColorsRes
                                                              .appColorWhite),
                                                ),
                                              ),
                                            ),
                                          if (ordersProvider
                                                  .ordersStatusState ==
                                              OrderUpdateStatusState.loading)
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                top: Constant.paddingOrMargin10,
                                                start:
                                                    Constant.paddingOrMargin10,
                                                end: Constant.paddingOrMargin10,
                                              ),
                                              child: CustomShimmer(
                                                height: 55,
                                                width: double.maxFinite,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              });
                        },
                      ).then((value) async {
                        if (!Constant.session.isSeller()) {
                          callApi(reset: true);
                        }
                      });
                    },
                    child: Container(
                      alignment: AlignmentDirectional.centerStart,
                      padding:
                          EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorsRes.appColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextLabel(
                                  jsonKey: "status",
                                  style: TextStyle(
                                      fontSize: 14, color: ColorsRes.grey),
                                  softWrap: true,
                                ),
                                getSizedBox(height: 2),
                                CustomTextLabel(
                                  text: lblOrderStatusDisplayNames[
                                          int.parse(order.activeStatus ?? "0")]
                                      .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: ColorsRes.mainTextColor,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                  ),
                ),
                if (order.activeStatus.toString() == "5")
                  getSizedBox(width: 10),
                if (order.activeStatus.toString() == "5")
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          orderTrackerScreen,
                          arguments: [
                            order.latitude?.toDouble,
                            order.longitude?.toDouble,
                            order.address.toString(),
                            order.id.toString(),
                            order.userName.toString(),
                            order.userMobile.toString(),
                          ],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorsRes.appColor,
                        ),
                        height: 55,
                        alignment: Alignment.center,
                        child: CustomTextLabel(
                          jsonKey: "start_tracking",
                          style: TextStyle(
                            color: ColorsRes.mainTextColor,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildOrderContainerShimmer() {
    return CustomShimmer(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.25,
      borderRadius: 10,
      margin: EdgeInsetsDirectional.only(
          start: Constant.paddingOrMargin10,
          end: Constant.paddingOrMargin10,
          bottom: Constant.paddingOrMargin10),
    );
  }
}
