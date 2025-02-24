import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

getItemDetailContainer({required String title, required String value}) {
  return Row(
    children: [
      CustomTextLabel(
        text: title,
        softWrap: true,
        style: TextStyle(color: ColorsRes.grey),
      ),
      getSizedBox(width: 10),
      Expanded(
        child: CustomTextLabel(
          text: value,
          softWrap: true,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
    ],
  );
}
