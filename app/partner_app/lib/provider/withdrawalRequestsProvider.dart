import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/withdrawalRequest.dart';
import 'package:project/repositories/withdrawalRequestsApi.dart';

enum WithdrawalRequestsState {
  initial,
  loading,
  loaded,
  loadingMore,
  empty,
  error,
}

class WithdrawalRequestsProvider extends ChangeNotifier {
  WithdrawalRequestsState withdrawalRequestsState =
      WithdrawalRequestsState.initial;
  String message = '';
  List<WithdrawRequests> withdrawalRequestsList = [];
  String availableBalance = "10782.98";
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getWithdrawalRequestProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
    required bool isSilentLoading,
  }) async {
    if (!isSilentLoading) {
      if (offset == 0) {
        withdrawalRequestsState = WithdrawalRequestsState.loading;
      } else {
        withdrawalRequestsState = WithdrawalRequestsState.loadingMore;
      }
      notifyListeners();
    }

    try {
      params[ApiAndParams.limit] = params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          (await getWithdrawalRequestsApi(context: context, params: params));

      if (getData[ApiAndParams.status].toString() == "1") {
        Map<String, dynamic> data = getData["data"];

        totalData = int.parse(getData["total"].toString());

        availableBalance = data["balance"].toString();

        if (data.containsKey("withdraw_requests")) {
          List<WithdrawRequests> tempWithdrawalRequests =
              (data["withdraw_requests"] as List)
                  .map((e) => WithdrawRequests.fromJson(Map.from(e)))
                  .toList();

          withdrawalRequestsList.addAll(tempWithdrawalRequests);
        }
        hasMoreData = totalData > withdrawalRequestsList.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        if (totalData > 0) {
          withdrawalRequestsState = WithdrawalRequestsState.loaded;
          notifyListeners();
        } else {
          withdrawalRequestsState = WithdrawalRequestsState.empty;
          notifyListeners();
        }
      } else {
        withdrawalRequestsState = WithdrawalRequestsState.error;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      withdrawalRequestsState = WithdrawalRequestsState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
    }
  }
}
