import 'package:project/helper/utils/generalImports.dart';

class OrderItemContainer extends StatelessWidget {
  final Order order;
  final String from;

  const OrderItemContainer(
      {super.key, required this.order, required this.from});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, orderDetailScreen,
            arguments: [order.id, from]).then((value) {
          if (value != null) {
            context.read<ActiveOrdersProvider>().updateOrder(value as Order);
          }
        });
      },
      child: Container(
        margin: EdgeInsetsDirectional.only(start: 10, end: 10, top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsetsDirectional.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextLabel(
                        text:
                            "${getTranslatedValue(context, "order")} #${order.id}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                      CustomTextLabel(
                        text: "${order.date.toString().formatDate()}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ColorsRes.subTitleMainTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.all(10),
                  decoration: BoxDecoration(
                    color: ColorsRes
                        .statusBgColor[order.activeStatus.toString().toInt - 1],
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: ColorsRes.statusTextColor[
                          order.activeStatus.toString().toInt - 1],
                      width: 1,
                    ),
                  ),
                  child: CustomTextLabel(
                    jsonKey: Constant.getOrderActiveStatusLabelFromCode(
                      order.activeStatus.toString(),
                      context,
                    ),
                    style: TextStyle(
                      color: ColorsRes.statusTextColor[
                          order.activeStatus.toString().toInt - 1],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            getSizedBox(
              height: 10,
            ),
            getDivider(
              color: ColorsRes.subTitleMainTextColor.withOpacity(0.3),
              height: 1,
              thickness: 1,
            ),
            getSizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...List.generate(
                  order.items!.length >= 3 ? 3 : order.items!.length,
                  (itemIndex) {
                    return Row(
                      children: [
                        Icon(
                          Icons.circle_rounded,
                          size: 7,
                          color: ColorsRes.subTitleMainTextColor,
                        ),
                        getSizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: CustomTextLabel(
                            text: order.items?[itemIndex].productName,
                            style: TextStyle(
                              color: ColorsRes.subTitleMainTextColor,
                            ),
                          ),
                        ),
                        CustomTextLabel(
                          text:
                              "${order.items?[itemIndex].measurement} ${order.items?[itemIndex].unit}",
                          style: TextStyle(
                            color: ColorsRes.subTitleMainTextColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (order.items!.length > 3) ...[
                  getSizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsetsDirectional.only(
                        start: 15, end: 15, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: ColorsRes.subTitleMainTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CustomTextLabel(
                      text:
                          "+ ${order.items!.length - 3} ${(order.items!.length - 3) == 1 ? getTranslatedValue(context, "item") : getTranslatedValue(context, "items")}",
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ]
              ],
            ),
            getSizedBox(
              height: 10,
            ),
            getDivider(
              color: ColorsRes.subTitleMainTextColor.withOpacity(0.3),
              height: 1,
              thickness: 1,
            ),
            getSizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomTextLabel(
                    jsonKey: "total_pay",
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorsRes.mainTextColor,
                    ),
                  ),
                ),
                CustomTextLabel(
                  jsonKey: order.finalTotal.toString().currency,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorsRes.appColor,
                  ),
                ),
              ],
            ),
            getSizedBox(
              height: 10,
            ),
            getDivider(
              color: ColorsRes.subTitleMainTextColor.withOpacity(0.3),
              height: 1,
              thickness: 1,
            ),
            getSizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsetsDirectional.all(10),
                    child: CustomTextLabel(
                      jsonKey: "show_more",
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (order.status!.isNotEmpty &&
                          order.activeStatus.toString() != "5") {
                        showModalBottomSheet(
                          backgroundColor: Theme.of(context).cardColor,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          context: context,
                          builder: (context) {
                            return OrderTrackingHistoryBottomSheet(
                              listOfStatus: order.status ?? [],
                            );
                          },
                        );
                      } else if (order.activeStatus.toString() == "5") {
                        Navigator.pushNamed(
                          context,
                          orderTrackerScreen,
                          arguments: [
                            order.latitude?.toDouble,
                            order.longitude?.toDouble,
                            order.orderAddress.toString(),
                            order.id.toString(),
                            order.deliveryBoyName.toString(),
                            order.deliveryBoyNumber.toString(),
                          ],
                        );
                      } else {
                        showMessage(
                            context,
                            getTranslatedValue(context, "order_awaiting_payment_track_order_message"),
                            MessageType.warning);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorsRes.mainTextColorLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsetsDirectional.all(10),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextLabel(
                            jsonKey: "track_my_order",
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorsRes.mainTextColorDark,
                            ),
                          ),
                          getSizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: ColorsRes.mainTextColorDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
