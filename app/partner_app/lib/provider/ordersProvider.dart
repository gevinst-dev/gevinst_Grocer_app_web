import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

enum OrdersState {
  initial,
  loading,
  silentLoading,
  loaded,
  empty,
  loadingMore,
  error,
}

class OrdersProvider extends ChangeNotifier {
  String message = '';
  OrdersState ordersState = OrdersState.initial;

  late SellerOrder sellerOrderData;
  List<SellerOrdersListItem> sellerOrdersList = [];

  late DeliveryBoyOrder deliveryBoyOrderData;
  List<DeliveryBoyOrdersListItem> deliveryBoyOrdersList = [];

  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;
  int selectedStatus = 0;

  Future getOrders({
    required BuildContext context,
    required Map<String, String> params,
  }) async {
    if (offset == 0) {
      ordersState = OrdersState.loading;
      notifyListeners();
    } else if (ordersState == OrdersState.loaded) {
      ordersState = OrdersState.silentLoading;
      notifyListeners();
    } else {
      ordersState = OrdersState.loadingMore;
      notifyListeners();
    }

    try {
      params[ApiAndParams.status] = selectedStatus.toString();
      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          await getOrdersRepository(context: context, params: params);

      if (getData[ApiAndParams.status].toString() == "1") {
        if (Constant.session.isSeller() == true) {
          sellerOrderData = SellerOrder.fromJson(getData);
          totalData = sellerOrderData.data?.statusOrderCount?[selectedStatus]
                  .orderCount?.toStringToInt ??
              0;
          List<SellerOrdersListItem> tempOrders =
              sellerOrderData.data?.orders ?? [];

          if (ordersState == OrdersState.silentLoading) {
            sellerOrdersList.clear();
          }

          sellerOrdersList.addAll(tempOrders);
          hasMoreData = totalData > sellerOrdersList.length;
          if (hasMoreData) {
            offset = offset + Constant.defaultDataLoadLimitAtOnce;
          }
          if (totalData == 0) {
            ordersState = OrdersState.empty;
            notifyListeners();
          } else {
            ordersState = OrdersState.loaded;
            notifyListeners();
          }
        } else {
          deliveryBoyOrderData = DeliveryBoyOrder.fromJson(getData);
          totalData = getData[ApiAndParams.total];
          List<DeliveryBoyOrdersListItem> tempOrders =
              deliveryBoyOrderData.data?.orders ?? [];

          if (ordersState == OrdersState.silentLoading) {
            deliveryBoyOrdersList.clear();
          }

          deliveryBoyOrdersList.addAll(tempOrders);

          hasMoreData = totalData > deliveryBoyOrdersList.length;
          if (hasMoreData) {
            offset = offset + Constant.defaultDataLoadLimitAtOnce;
          }
          if (totalData == 0) {
            ordersState = OrdersState.empty;
            notifyListeners();
          } else {
            ordersState = OrdersState.loaded;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      message = e.toString();
      ordersState = OrdersState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
    }
  }

  Future<bool> changeOrderSelectedStatus(int index) async {
    if (selectedStatus.toString() != index.toString()) {
      selectedStatus = index;
      notifyListeners();
      offset = 0;
      sellerOrdersList = [];
      deliveryBoyOrdersList = [];
      return true;
    } else {
      return false;
    }
  }
}
