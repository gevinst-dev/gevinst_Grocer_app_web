import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

getOrderDetailContainer({required String title, required String value}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 5,
        child: CustomTextLabel(
          text: title,
          softWrap: true,
          style: TextStyle(color: ColorsRes.grey),
        ),
      ),
      getSizedBox(width: 10),
      Expanded(
        flex: 10,
        child: CustomTextLabel(
          text: value,
          softWrap: true,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
    ],
  );
}
