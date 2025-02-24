import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/ordersStatusUpdateProvider.dart';

class OrderContainer extends StatelessWidget {
  final SellerOrdersListItem order;
  final String index;
  final VoidCallback? callApi;
  final List<String> lblOrderStatusDisplayNames;
  final List<String> lblOrderStatusUpdateNames;

  const OrderContainer({
    super.key,
    required this.order,
    required this.index,
    this.callApi,
    required this.lblOrderStatusDisplayNames,
    required this.lblOrderStatusUpdateNames,
  });

  @override
  Widget build(BuildContext context) {
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
                    fontWeight: FontWeight.bold,
                    color: ColorsRes.appColor,
                  ),
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
              height: 10,
            ),
            Divider(height: 1, color: ColorsRes.grey, thickness: 0),
            getSizedBox(
              height: 10,
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
            getSizedBox(height: 20),
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
                            create: (context) => DeliveryBoysProvider(),
                            builder: (context, child) {
                              if (context
                                      .read<DeliveryBoysProvider>()
                                      .deliveryBoysState ==
                                  ProductDeliveryBoysState.initial) {
                                context
                                    .read<DeliveryBoysProvider>()
                                    .getDeliveryBoys(
                                        selectedDeliveryBoyIndex: int.parse(
                                          "${order.deliveryBoyId.toString().isEmpty ? "0" : order.deliveryBoyId.toString()}",
                                        ),
                                        context: context);
                              }

                              return Consumer<DeliveryBoysProvider>(
                                builder:
                                    (context, deliveryBoysProvider, child) {
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
                                            jsonKey: "update_delivery_boy",
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .merge(
                                                  TextStyle(
                                                    letterSpacing: 0.5,
                                                    color:
                                                        ColorsRes.mainTextColor,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        getSizedBox(
                                          height: 10,
                                        ),
                                        if (deliveryBoysProvider
                                                    .deliveryBoysState ==
                                                ProductDeliveryBoysState
                                                    .loaded ||
                                            deliveryBoysProvider
                                                    .deliveryBoysState ==
                                                ProductDeliveryBoysState
                                                    .loadingMore ||
                                            deliveryBoysProvider
                                                    .deliveryBoysState ==
                                                ProductDeliveryBoysState
                                                    .updating)
                                          Column(
                                            children: List.generate(
                                                deliveryBoysProvider
                                                    .deliveryBoysList
                                                    .length, (index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  deliveryBoysProvider
                                                      .setSelectedIndex(
                                                    deliveryBoysProvider
                                                        .deliveryBoysList[index]
                                                        .id
                                                        .toString(),
                                                  );
                                                },
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsetsDirectional
                                                              .only(
                                                                  start: Constant
                                                                      .paddingOrMargin10),
                                                          child:
                                                              CustomTextLabel(
                                                            text:
                                                                "${deliveryBoysProvider.deliveryBoysList[index].name ?? ""}(${getTranslatedValue(context, "pending_orders")} - ${deliveryBoysProvider.deliveryBoysList[index].pendingOrderCount ?? "0"})",
                                                          ),
                                                        ),
                                                      ),
                                                      Radio(
                                                        activeColor:
                                                            ColorsRes.appColor,
                                                        value: context
                                                            .watch<
                                                                DeliveryBoysProvider>()
                                                            .selectedDeliveryBoy,
                                                        groupValue:
                                                            deliveryBoysProvider
                                                                .deliveryBoysList[
                                                                    index]
                                                                .id
                                                                .toString(),
                                                        onChanged: (value) {
                                                          deliveryBoysProvider
                                                              .setSelectedIndex(
                                                            deliveryBoysProvider
                                                                .deliveryBoysList[
                                                                    index]
                                                                .id
                                                                .toString(),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        if (deliveryBoysProvider
                                                .deliveryBoysState ==
                                            ProductDeliveryBoysState.loading)
                                          Column(
                                            children: List.generate(8, (index) {
                                              return CustomShimmer(
                                                height: 30,
                                                width: double.maxFinite,
                                                margin:
                                                    EdgeInsetsDirectional.all(
                                                        10),
                                              );
                                            }),
                                          ),
                                        getSizedBox(
                                          height: 10,
                                        ),
                                        if (deliveryBoysProvider
                                                    .deliveryBoysState ==
                                                ProductDeliveryBoysState
                                                    .updating ||
                                            deliveryBoysProvider
                                                    .deliveryBoysState ==
                                                ProductDeliveryBoysState.loaded)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    Constant.paddingOrMargin10),
                                            child: gradientBtnWidget(
                                              context,
                                              10,
                                              callback: () {
                                                Map<String, String> params = {};
                                                params[ApiAndParams.orderId] =
                                                    order.orderId.toString();
                                                params[ApiAndParams
                                                        .deliveryBoyId] =
                                                    deliveryBoysProvider
                                                        .selectedDeliveryBoy
                                                        .toString();

                                                deliveryBoysProvider
                                                    .updateOrdersDeliveryBoy(
                                                        params: params,
                                                        context: context)
                                                    .then(
                                                      (value) => Navigator.pop(
                                                          context, value),
                                                    );
                                              },
                                              otherWidgets: Container(
                                                child: (deliveryBoysProvider
                                                            .deliveryBoysState ==
                                                        ProductDeliveryBoysState
                                                            .updating)
                                                    ? CircularProgressIndicator(
                                                        color: ColorsRes
                                                            .appColorWhite)
                                                    : (deliveryBoysProvider
                                                                .deliveryBoysState ==
                                                            ProductDeliveryBoysState
                                                                .loaded)
                                                        ? CustomTextLabel(
                                                            jsonKey:
                                                                "update_delivery_boy",
                                                            softWrap: true,
                                                            style: Theme.of(
                                                                    context)
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
                                                        : Container(),
                                              ),
                                            ),
                                          ),
                                        if (deliveryBoysProvider
                                                .deliveryBoysState ==
                                            ProductDeliveryBoysState.loading)
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: Constant.paddingOrMargin10,
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
                            },
                          );
                        },
                      ).then(
                        (value) => callApi,
                      );
                    },
                    child: Container(
                      alignment: AlignmentDirectional.centerStart,
                      margin: EdgeInsetsDirectional.only(end: 5),
                      padding:
                          EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                                  jsonKey: "delivery_boy",
                                  style: TextStyle(
                                      fontSize: 14, color: ColorsRes.grey),
                                  softWrap: true,
                                ),
                                getSizedBox(height: 2),
                                CustomTextLabel(
                                  text:
                                      "${(order.deliveryBoyName == null || order.deliveryBoyName == "null") ? getTranslatedValue(context, "not_assign") : order.deliveryBoyName}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: ColorsRes.mainTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet<Future>(
                        backgroundColor: Theme.of(context).cardColor,
                        context: context,
                        isScrollControlled: true,
                        shape: DesignConfig.setRoundedBorderSpecific(20,
                            istop: true),
                        builder: (BuildContext context) {
                          return ChangeNotifierProvider(
                            create: (context) => OrderUpdateStatusProvider(),
                            builder: (context, child) {
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
                              return Consumer<OrderUpdateStatusProvider>(
                                  builder: (_, ordersProvider, __) {
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
                                                  color:
                                                      ColorsRes.mainTextColor,
                                                ),
                                              ),
                                        ),
                                      ),
                                      getSizedBox(
                                        height: 10,
                                      ),
                                      if (ordersProvider.ordersStatusState ==
                                              OrderUpdateStatusState.loaded ||
                                          ordersProvider.ordersStatusState ==
                                              OrderUpdateStatusState.updating)
                                        Column(
                                          children: List.generate(
                                              ordersProvider.orderStatusesList
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
                                                        padding: EdgeInsetsDirectional
                                                            .only(
                                                                start: Constant
                                                                    .paddingOrMargin10),
                                                        child: CustomTextLabel(
                                                          jsonKey:
                                                              lblOrderStatusUpdateNames[
                                                                  index],
                                                        ),
                                                      ),
                                                    ),
                                                    Radio(
                                                      activeColor:
                                                          ColorsRes.appColor,
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
                                      if (ordersProvider.ordersStatusState ==
                                          OrderUpdateStatusState.loading)
                                        Column(
                                          children: List.generate(8, (index) {
                                            return CustomShimmer(
                                              height: 26,
                                              width: double.maxFinite,
                                              margin:
                                                  EdgeInsetsDirectional.all(10),
                                            );
                                          }),
                                        ),
                                      if (ordersProvider.ordersStatusState ==
                                              OrderUpdateStatusState.loaded ||
                                          ordersProvider.ordersStatusState ==
                                              OrderUpdateStatusState.updating)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Constant.paddingOrMargin10),
                                          child: gradientBtnWidget(
                                            context,
                                            10,
                                            callback: () {
                                              Map<String, String> params = {};
                                              params[ApiAndParams.orderId] =
                                                  order.orderId.toString();
                                              params[ApiAndParams.statusId] =
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
                                                        Navigator.pop(context),
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
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .merge(
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                                          .appColorWhite,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      if (ordersProvider.ordersStatusState ==
                                          OrderUpdateStatusState.loading)
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            top: Constant.paddingOrMargin10,
                                            start: Constant.paddingOrMargin10,
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
                              });
                            },
                          );
                        },
                      ).then(
                        (value) => callApi,
                      );
                    },
                    child: Container(
                      alignment: AlignmentDirectional.centerStart,
                      padding:
                          EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                      margin: EdgeInsetsDirectional.only(start: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
              ],
            )
          ],
        ),
      ),
    );
  }
}
