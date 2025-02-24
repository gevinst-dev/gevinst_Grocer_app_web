import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/sendWithdrawalRequestsProvider.dart';

class BottomSheetWithdrawalRequestListContainer extends StatefulWidget {
  final String availableWalletBalance;

  BottomSheetWithdrawalRequestListContainer({
    Key? key,
    required this.availableWalletBalance,
  }) : super(key: key);

  @override
  State<BottomSheetWithdrawalRequestListContainer> createState() =>
      _BottomSheetWithdrawalRequestListContainerState();
}

class _BottomSheetWithdrawalRequestListContainerState
    extends State<BottomSheetWithdrawalRequestListContainer> {
  TextEditingController edtWithdrawalRequestAmount = TextEditingController();
  TextEditingController edtRemark = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        } else {
          Navigator.pop(context, false);
        }
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 20,
          end: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            getSizedBox(
              height: 20,
            ),
            Center(
              child: CustomTextLabel(
                jsonKey: "withdrawal_request",
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.merge(
                      TextStyle(
                        letterSpacing: 0.5,
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
              ),
            ),
            getSizedBox(
              height: 10,
            ),
            editBoxWidget(
              context: context,
              edtController: edtWithdrawalRequestAmount,
              validationFunction: emptyValidation,
              label: getTranslatedValue(context, "withdrawal_request_amount"),
              inputType: TextInputType.number,
              bgcolor: Theme.of(context).cardColor,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+\.?\d*'),
                ),
              ],
            ),
            getSizedBox(
              height: 10,
            ),
            editBoxWidget(
              context: context,
              edtController: edtRemark,
              bgcolor: Theme.of(context).cardColor,
              validationFunction: emptyValidation,
              label: getTranslatedValue(context, "remark"),
              inputType: TextInputType.text,
            ),
            getSizedBox(
              height: 10,
            ),
            Consumer<SendWithdrawalRequestsProvider>(
              builder: (context, sendWithdrawalRequestsProvider, _) {
                return gradientBtnWidget(
                  context,
                  10,
                  callback: () {
                    if (edtWithdrawalRequestAmount.text.isEmpty) {
                      showMessage(
                          context,
                          getTranslatedValue(context, "enter_valid_amount"),
                          MessageType.error);
                    } else if (edtWithdrawalRequestAmount.text
                            .toString()
                            .toDouble! >
                        NumberFormat.currency(
                                decimalDigits: int.parse(
                                    Constant.currencyDecimalPoint.toString()),
                                customPattern: "")
                            .format(widget.availableWalletBalance.toDouble!)
                            .toDouble!) {
                      showMessage(
                          context,
                          getTranslatedValue(context,
                              "requested_amount_should_not_greater_then_available_balance"),
                          MessageType.error);
                    } else if (edtRemark.text.toString().isEmpty) {
                      showMessage(
                          context,
                          getTranslatedValue(context, "add_remark"),
                          MessageType.error);
                    } else if (edtWithdrawalRequestAmount.text.isNotEmpty &&
                        edtWithdrawalRequestAmount.text.toString().toDouble! <
                            0.01) {
                      showMessage(
                          context,
                          "${getTranslatedValue(context, "requested_amount_should_greater_then")} ${"0.01".currency}",
                          MessageType.error);
                    } else if (!sendWithdrawalRequestsProvider.sendingRequest) {
                      sendWithdrawalRequestsProvider
                          .sendWithdrawalRequestProvider(params: {
                        ApiAndParams.type: Constant.session.isSeller()
                            ? "seller"
                            : "delivery_boy",
                        ApiAndParams.typeId:
                            Constant.session.isSeller() ? "0" : "1",
                        ApiAndParams.amount:
                            edtWithdrawalRequestAmount.text.toString(),
                        ApiAndParams.message: edtRemark.text.toString()
                      }, context: context).then((value) {
                        if (value is bool && value == true) {
                          showMessage(
                            context,
                            getTranslatedValue(context, "request_sent"),
                            MessageType.success,
                          );
                          if (value) {
                            Navigator.pop(context, value);
                          }
                        }
                      });
                    }
                  },
                  height: 55,
                  otherWidgets: sendWithdrawalRequestsProvider
                              .sendWithdrawalRequestsState ==
                          SendWithdrawalRequestsState.loading
                      ? CircularProgressIndicator(
                          color: ColorsRes.appColorWhite,
                        )
                      : CustomTextLabel(
                          jsonKey: "send_request",
                          style: TextStyle(
                            color: ColorsRes.appColorWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                );
              },
            ),
            getSizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
