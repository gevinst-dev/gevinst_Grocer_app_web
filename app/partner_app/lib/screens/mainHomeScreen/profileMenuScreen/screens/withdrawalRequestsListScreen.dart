import 'package:flutter/material.dart';
import 'package:project/helper/generalWidgets/bottomSheetWithdrawalRequestContainer.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/withdrawalRequest.dart';
import 'package:project/provider/sendWithdrawalRequestsProvider.dart';
import 'package:project/provider/withdrawalRequestsProvider.dart';

class WithdrawalRequestsListScreen extends StatefulWidget {
  const WithdrawalRequestsListScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalRequestsListScreen> createState() =>
      _WithdrawalRequestsListScreenState();
}

class _WithdrawalRequestsListScreenState
    extends State<WithdrawalRequestsListScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<WithdrawalRequestsProvider>().hasMoreData) {
          callApi(false, false);
        }
      }
    }
  }

  Future callApi(bool isReset, bool isSilentLoading) async {
    if (isReset == true) {
      context.read<WithdrawalRequestsProvider>().offset = 0;
      context.read<WithdrawalRequestsProvider>().withdrawalRequestsList = [];
    }
    return context
        .read<WithdrawalRequestsProvider>()
        .getWithdrawalRequestProvider(
            params: {ApiAndParams.search: searchController.text.toString()},
            context: context,
            isSilentLoading: isSilentLoading);
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
      callApi(true, false);
      searchController.addListener(() {
        callApi(true, false);
      });
    });

    scrollController.addListener(scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "withdrawal_requests",
            style: TextStyle(color: ColorsRes.mainTextColor),
          )),
      body: setRefreshIndicator(
        refreshCallback: () async {
          await callApi(true, false);
        },
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsetsDirectional.all(10),
              margin: EdgeInsetsDirectional.only(
                  start: 10, end: 10, top: 10, bottom: 5),
              decoration: DesignConfig.boxDecoration(
                Theme.of(context).cardColor,
                10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextLabel(
                          jsonKey: "wallet_balance",
                          style: TextStyle(
                            color: ColorsRes.appColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CustomTextLabel(
                          text:
                              "${context.watch<WithdrawalRequestsProvider>().availableBalance}"
                                  .currency,
                          style: TextStyle(
                            color: ColorsRes.appColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  gradientBtnWidget(
                    context,
                    7,
                    callback: () {
                      if (context
                              .read<WithdrawalRequestsProvider>()
                              .availableBalance
                              .toDouble! >
                          1.0) {
                        showModalBottomSheet<bool>(
                          backgroundColor: Theme.of(context).cardColor,
                          context: context,
                          isScrollControlled: true,
                          shape: DesignConfig.setRoundedBorderSpecific(20,
                              istop: true),
                          builder: (BuildContext context1) {
                            return Wrap(
                              children: [
                                ChangeNotifierProvider(
                                  create: (context) =>
                                      SendWithdrawalRequestsProvider(),
                                  child:
                                      BottomSheetWithdrawalRequestListContainer(
                                    availableWalletBalance: context
                                        .read<WithdrawalRequestsProvider>()
                                        .availableBalance,
                                  ),
                                ),
                              ],
                            );
                          },
                        ).then((value) async {
                          if (value == true) {
                            await callApi(true, true);
                          }
                        });
                      } else {
                        showMessage(
                            context,
                            "${getTranslatedValue(context, 'you_should_have_minimum')} ${"1.0".currency} ${getTranslatedValue(context, 'for_send_request')}",
                            MessageType.warning);
                      }
                    },
                    color1: context
                                .read<WithdrawalRequestsProvider>()
                                .availableBalance
                                .toDouble! >
                            1.0
                        ? ColorsRes.gradient1
                        : ColorsRes.grey,
                    color2: context
                                .read<WithdrawalRequestsProvider>()
                                .availableBalance
                                .toDouble! >
                            1.0
                        ? ColorsRes.gradient2
                        : ColorsRes.grey,
                    padding: EdgeInsetsDirectional.only(start: 10, end: 10),
                    title: getTranslatedValue(context, "withdrawal_request"),
                    height: 40,
                  ),
                ],
              ),
            ),
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
            Consumer<WithdrawalRequestsProvider>(
              builder: (_, withdrawalRequestsProvider, __) {
                if (withdrawalRequestsProvider.withdrawalRequestsState ==
                        WithdrawalRequestsState.initial ||
                    withdrawalRequestsProvider.withdrawalRequestsState ==
                        WithdrawalRequestsState.loading) {
                  return getTransactionListShimmer();
                } else if (withdrawalRequestsProvider.withdrawalRequestsState ==
                        WithdrawalRequestsState.loaded ||
                    withdrawalRequestsProvider.withdrawalRequestsState ==
                        WithdrawalRequestsState.loadingMore) {
                  return Column(
                    children: List.generate(
                        withdrawalRequestsProvider
                            .withdrawalRequestsList.length, (index) {
                      return getWithdrawalRequestsItemWidget(
                          withdrawalRequestsProvider
                              .withdrawalRequestsList[index]);
                    }),
                  );
                } else {
                  return DefaultBlankItemMessageScreen(
                    image: "no_transaction",
                    title: getTranslatedValue(
                        context, "empty_withdrawal_requests_list_message"),
                    description: getTranslatedValue(context,
                        "empty_withdrawal_requests_transaction_description"),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  getWithdrawalRequestsItemWidget(WithdrawRequests withdrawalRequests) {
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
                  text: "ID #${withdrawalRequests.id}",
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
                  withdrawalRequests.status?.toLowerCase() == "0"
                      ? ColorsRes.appColorOrange.withOpacity(0.1)
                      : withdrawalRequests.status == "1"
                          ? ColorsRes.appColorGreen.withOpacity(0.1)
                          : ColorsRes.appColorRed.withOpacity(0.1),
                  5,
                  bordercolor: withdrawalRequests.status?.toLowerCase() == "0"
                      ? ColorsRes.appColorOrange
                      : withdrawalRequests.status == "1"
                          ? ColorsRes.appColorGreen
                          : ColorsRes.appColorRed,
                  isboarder: true,
                  borderwidth: 1,
                ),
                child: CustomTextLabel(
                  jsonKey: withdrawalRequests.status == "0"
                      ? "pending"
                      : withdrawalRequests.status == "1"
                          ? "approved"
                          : "rejected",
                  style: TextStyle(
                    color: withdrawalRequests.status?.toLowerCase() == "0"
                        ? ColorsRes.appColorOrange
                        : withdrawalRequests.status == "1"
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
            text: withdrawalRequests.message.toString(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextLabel(
                text: withdrawalRequests.createdAt.toString().formatDate(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ColorsRes.mainTextColor,
                ),
                softWrap: true,
              ),
              if (withdrawalRequests.receiptImageUrl.toString().isNotEmpty &&
                  withdrawalRequests.receiptImageUrl.toString() != "" &&
                  withdrawalRequests.receiptImageUrl.toString() != "null")
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      fullScreenProductImageScreen,
                      arguments: [
                        0,
                        [withdrawalRequests.receiptImageUrl.toString()],
                      ],
                    );
                  },
                  child: Container(
                    padding: EdgeInsetsDirectional.only(
                        start: 10, end: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: ColorsRes.appColor,
                      ),
                    ),
                    child: CustomTextLabel(
                      jsonKey: "check_receipt",
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
            ],
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
                text: withdrawalRequests.amount?.currency,
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
