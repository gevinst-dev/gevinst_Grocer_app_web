import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

profileHeader(
    {required BuildContext context,
    required String name,
    required String mobile}) {
  return GestureDetector(
    onTap: () {
      if (Constant.session.isSeller()) {
        Navigator.pushNamed(context, editSellerProfileScreen, arguments: "");
      } else {
        Navigator.pushNamed(context, editDeliveryBoyProfileScreen,
            arguments: "");
      }
    },
    child: Card(
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsetsDirectional.only(bottom: 5, start: 3, end: 3),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: CustomTextLabel(
                      text: name,
                    ),
                    subtitle: CustomTextLabel(
                      text: mobile,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: ColorsRes.appColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Container(
              decoration: DesignConfig.boxGradient(5),
              padding: EdgeInsets.all(5),
              margin: EdgeInsetsDirectional.only(end: 8, top: 8),
              child: defaultImg(
                  image: "edit_icon",
                  iconColor: Colors.white,
                  height: 20,
                  width: 20),
            ),
          ),
        ],
      ),
    ),
  );
}
