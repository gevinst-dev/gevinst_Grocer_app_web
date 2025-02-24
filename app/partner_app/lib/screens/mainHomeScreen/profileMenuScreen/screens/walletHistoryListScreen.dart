import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/walletHistory.dart';
import 'package:project/provider/walletHistoryListProvider.dart';

class WalletHistoryListScreen extends StatefulWidget {
  const WalletHistoryListScreen({Key? key}) : super(key: key);

  @override
  State<WalletHistoryListScreen> createState() =>
      _WalletHistoryListScreenState();
}

class _WalletHistoryListScreenState extends State<WalletHistoryListScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<WalletHistoryProvider>().hasMoreData) {
          callApi();
        }
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      searchController.addListener(() {
        callApi(reset: true);
      });
      callApi();
    });

    scrollController.addListener(scrollListener);

    super.initState();
  }

  callApi({bool? reset}) async {
    if (reset == true) {
      context.read<WalletHistoryProvider>().offset = 0;
      context.read<WalletHistoryProvider>().walletHistories = [];
    }

    context.read<WalletHistoryProvider>().getWalletHistoryProvider(
        params: {ApiAndParams.search: searchController.text.toString()},
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "wallet_history",
            style: TextStyle(color: ColorsRes.mainTextColor),
          )),
      body: setRefreshIndicator(
        refreshCallback: () {
          return callApi(reset: true);
        },
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 10, end: 10, top: 10),
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
            Consumer<WalletHistoryProvider>(
              builder: (context, walletHistoryProvider, _) {
                if (walletHistoryProvider.walletHistoryState ==
                        WalletHistoryState.initial ||
                    walletHistoryProvider.walletHistoryState ==
                        WalletHistoryState.loading) {
                  return getTransactionListShimmer();
                } else if (walletHistoryProvider.walletHistoryState ==
                        WalletHistoryState.loaded ||
                    walletHistoryProvider.walletHistoryState ==
                        WalletHistoryState.loadingMore) {
                  return Column(
                    children: List.generate(
                        walletHistoryProvider.walletHistories.length, (index) {
                      return getWalletHistoryItemWidget(
                          walletHistoryProvider.walletHistories[index]);
                    }),
                  );
                } else {
                  return DefaultBlankItemMessageScreen(
                    image: "no_transaction",
                    title: getTranslatedValue(
                        context, "empty_wallet_history_list_message"),
                    description: getTranslatedValue(context,
                        "empty_wallet_history_transaction_description"),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  getWalletHistoryItemWidget(WalletHistoryData walletHistory) {
    String message = walletHistory.message.toString();
    if ((walletHistory.orderId == null || walletHistory.orderId == "null") &&
        (walletHistory.orderItemId == null ||
            walletHistory.orderItemId == "null")) {
      message = walletHistory.message.toString();
    } else if ((walletHistory.orderId != null ||
            walletHistory.orderId != "null") &&
        (walletHistory.orderItemId != null ||
            walletHistory.orderItemId != "null") &&
        walletHistory.type.toString().toLowerCase() == "debit") {
      String orderId = walletHistory.orderId.toString() != "null"
          ? "-${getTranslatedValue(context, "order_id")}:${walletHistory.orderId.toString()}"
          : "";
      message = "${getTranslatedValue(context, "order_placed")}${orderId}";
    } else if ((walletHistory.orderId != null ||
            walletHistory.orderId != "null") &&
        (walletHistory.orderItemId != null ||
            walletHistory.orderItemId != "null") &&
        walletHistory.type.toString().toLowerCase() == "credit") {
      String orderDetail = (walletHistory.variantName.toString() != "null" &&
              walletHistory.productName.toString() != "null" &&
              walletHistory.orderId.toString() != "null")
          ? " [${getTranslatedValue(context, "order_id")}:${walletHistory.orderId.toString()}, ${getTranslatedValue(context, "item")}: ${walletHistory.productName} (${walletHistory.variantName})]"
          : "";
      message = "${walletHistory.message}${orderDetail}";
    }

    return Container(
      padding: EdgeInsets.all(Constant.paddingOrMargin10),
      margin: EdgeInsets.symmetric(
          vertical: Constant.paddingOrMargin5,
          horizontal: Constant.paddingOrMargin10),
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
                  text: "ID #${walletHistory.id}",
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ColorsRes.mainTextColor,
                  ),
                ),
              ),
              SizedBox(width: Constant.paddingOrMargin5),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: Constant.paddingOrMargin5,
                    horizontal: Constant.paddingOrMargin10),
                decoration: DesignConfig.boxDecoration(
                  walletHistory.type?.toLowerCase() == "credit"
                      ? ColorsRes.appColorGreen.withOpacity(0.1)
                      : ColorsRes.appColorRed.withOpacity(0.1),
                  5,
                  bordercolor: walletHistory.type?.toLowerCase() == "credit"
                      ? ColorsRes.appColorGreen
                      : ColorsRes.appColorRed,
                  isboarder: true,
                  borderwidth: 1,
                ),
                child: CustomTextLabel(
                  jsonKey: walletHistory.type == "credit" ? "credit" : "debit",
                  style: TextStyle(
                    color: walletHistory.type?.toLowerCase() == "credit"
                        ? ColorsRes.appColorGreen
                        : ColorsRes.appColorRed,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Constant.paddingOrMargin5),
          Divider(height: 1, color: ColorsRes.grey, thickness: 0),
          SizedBox(height: Constant.paddingOrMargin5),
          CustomTextLabel(
            jsonKey: "message",
            style: TextStyle(
              color: ColorsRes.grey,
            ),
            softWrap: true,
          ),
          SizedBox(height: Constant.paddingOrMargin2),
          CustomTextLabel(
            text: message,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ColorsRes.mainTextColor,
            ),
            softWrap: true,
          ),
          SizedBox(height: Constant.paddingOrMargin20),
          CustomTextLabel(
            jsonKey: "date_and_time",
            style: TextStyle(
              color: ColorsRes.grey,
            ),
            softWrap: true,
          ),
          SizedBox(height: Constant.paddingOrMargin2),
          CustomTextLabel(
            text: walletHistory.createdAt.toString().formatDate(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ColorsRes.mainTextColor,
            ),
            softWrap: true,
          ),
          SizedBox(height: Constant.paddingOrMargin5),
          Divider(height: 1, color: ColorsRes.grey, thickness: 0),
          SizedBox(height: Constant.paddingOrMargin5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextLabel(
                jsonKey: "amount",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ColorsRes.mainTextColor,
                ),
                softWrap: true,
              ),
              CustomTextLabel(
                text: walletHistory.amount?.currency,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: ColorsRes.appColor),
                softWrap: true,
              ),
            ],
          )
        ],
      ),
    );
  }

  getTransactionListShimmer() {
    return Column(
      children: List.generate(20, (index) => transactionItemShimmer()),
    );
  }

  transactionItemShimmer() {
    return CustomShimmer(
      margin: EdgeInsets.symmetric(
          vertical: Constant.paddingOrMargin10,
          horizontal: Constant.paddingOrMargin10),
      height: 180,
      width: context.width,
    );
  }
}
