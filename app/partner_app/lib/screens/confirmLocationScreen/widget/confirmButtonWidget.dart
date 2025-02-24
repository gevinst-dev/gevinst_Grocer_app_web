import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class ConfirmButtonWidget extends StatelessWidget {
  final VoidCallback voidCallback;

  ConfirmButtonWidget({Key? key, required this.voidCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.paddingOrMargin15,
        vertical: Constant.paddingOrMargin15,
      ),
      child: gradientBtnWidget(
        context,
        10,
        title: getTranslatedValue(
          context,
          "confirm_location",
        ),
        callback: voidCallback,
      ),
    );
  }
}
