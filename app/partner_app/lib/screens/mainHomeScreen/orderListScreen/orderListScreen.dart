import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/ordersProvider.dart';
import 'package:project/screens/mainHomeScreen/orderListScreen/widget/orderContainer.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late ScrollController scrollController = ScrollController()
    ..addListener(activeOrdersScrollListener);
  List<String> lblOrderStatusDisplayNames = [];
  List<String> lblOrderStatusUpdateNames = [];
  TextEditingController searchController = TextEditingController();

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

    params[ApiAndParams.search] = searchController.text.toString();

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
    Map<String, String> params = {};
    params[ApiAndParams.status] = "1";

    Future.delayed(
      Duration.zero,
      () {
        startDate = getTranslatedValue(context, "start_date");
        endDate = getTranslatedValue(context, "end_date");

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

        context.read<OrdersProvider>().getOrders(context: context, params: {});

        searchController.addListener(() {
          callApi();
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (lblOrderStatusDisplayNames.isEmpty) {
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
    }
    if (lblOrderStatusDisplayNames.isEmpty) {
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
    }

    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "orders",
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  List.generate(lblOrderStatusDisplayNames.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    if (mounted) {
                      await context
                          .read<OrdersProvider>()
                          .changeOrderSelectedStatus(index)
                          .then((value) async {
                        if (value) {
                          callApi(reset: true);
                        }
                      });
                    }
                  },
                  child: getOrderStatusContainer(
                    isActive:
                        context.watch<OrdersProvider>().selectedStatus == index,
                    svgIconName: Constant.orderStatusIcons[index],
                    context: context,
                    title: lblOrderStatusDisplayNames[index].toString(),
                  ),
                );
              }),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 10),
                  child: editBoxWidget(
                    maxlines: 1,
                    context: context,
                    edtController: searchController,
                    validationFunction: optionalFieldValidation,
                    label: getTranslatedValue(context, "search"),
                    hint: getTranslatedValue(context, "search"),
                    bgcolor: Theme.of(context).cardColor,
                    inputType: TextInputType.text,
                    tailIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: ColorsRes.mainTextColor,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              getSizedBox(width: 10),
              Container(
                padding: EdgeInsetsDirectional.all(10),
                decoration: BoxDecoration(
                  color: ColorsRes.appColorLightHalfTransparent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 100, 1, 1),
                      lastDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      keyboardType: TextInputType.datetime,
                      builder: (context, child) {
                        return Theme(
                          data: Constant.session
                                  .getBoolData(SessionManager.isDarkTheme)
                              ? ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: ColorsRes.appColor,
                                    onPrimary: ColorsRes.mainTextColor,
                                    surface: Theme.of(context).cardColor,
                                    inverseSurface: ColorsRes.subTitleTextColor,
                                    onSurface: ColorsRes.mainTextColor,
                                    secondary: ColorsRes.appColor,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  dialogBackgroundColor:
                                      Theme.of(context).cardColor,
                                )
                              : ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: ColorsRes.appColor,
                                    onPrimary: ColorsRes.mainTextColor,
                                    surface: Theme.of(context).cardColor,
                                    onSurface: ColorsRes.mainTextColor,
                                    inverseSurface: ColorsRes.subTitleTextColor,
                                    secondary: ColorsRes.appColor,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  dialogBackgroundColor:
                                      Theme.of(context).cardColor,
                                ),
                          child: child!,
                        );
                      },
                    ).then(
                      (value) {
                        if (value != null) {
                          startDate = value.start.toString().split(" ")[0];
                          endDate = value.end.toString().split(" ")[0];

                          context.read<OrdersProvider>().offset = 0;
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
                    color: ColorsRes.appColor,
                  ),
                ),
              ),
              getSizedBox(width: 10),
            ],
          ),
          if (isDateRangeValidate())
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 10,
                end: 10,
                top: 10,
              ),
              child: Container(
                padding: EdgeInsetsDirectional.all(
                    (!isDateRangeValidate()) ? 12 : 14),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsRes.subTitleTextColor),
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
                  ordersProvider.ordersState == OrdersState.loadingMore ||
                  ordersProvider.ordersState == OrdersState.silentLoading) {
                return Expanded(
                  child: setRefreshIndicator(
                    refreshCallback: () {
                      return callApi(reset: true);
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: ordersProvider.sellerOrdersList.length,
                      itemBuilder: (context, index) {
                        if (index ==
                            ordersProvider.sellerOrdersList.length - 1) {
                          if (ordersProvider.ordersState ==
                              OrdersState.loadingMore) {
                            return OrderContainerShimmer(context);
                          }
                        }
                        return OrderContainer(
                          order: ordersProvider.sellerOrdersList[index],
                          index: index.toString(),
                          lblOrderStatusDisplayNames:
                              lblOrderStatusDisplayNames,
                          lblOrderStatusUpdateNames: lblOrderStatusUpdateNames,
                          callApi: () => callApi(reset: true),
                        );
                      },
                    ),
                  ),
                );
              } else if (ordersProvider.ordersState == OrdersState.loading) {
                return Expanded(
                  child: setRefreshIndicator(
                    refreshCallback: () {
                      return callApi(reset: true);
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return OrderContainerShimmer(context);
                      },
                    ),
                  ),
                );
              } else if (ordersProvider.ordersState == OrdersState.empty) {
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      DefaultBlankItemMessageScreen(
                        image: "no_order_icon",
                        title: "empty_orders_message",
                        description: "empty_orders_description",
                        buttonTitle: "refresh",
                        callback: () async {
                          return callApi();
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      DefaultBlankItemMessageScreen(
                        image: "something_went_wrong",
                        title: "something_went_wrong_message_title",
                        description: "something_went_wrong_message_description",
                        buttonTitle: "try_again",
                        callback: () async {
                          return callApi(reset: true);
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
