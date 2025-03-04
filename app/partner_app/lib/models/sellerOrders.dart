import '../helper/utils/generalImports.dart';

class SellerOrder {
  SellerOrder({
    this.status,
    this.message,
    this.total,
    this.data,
  });

  late final String? status;
  late final String? message;
  late final String? total;
  late final SellerOrderData? data;

  SellerOrder.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    data = SellerOrderData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['total'] = total;
    _data['data'] = data?.toJson();
    return _data;
  }
}

class SellerOrderData {
  SellerOrderData({
    this.statusOrderCount,
    this.orders,
  });

  late final List<StatusOrderCount>? statusOrderCount;
  late final List<SellerOrdersListItem>? orders;

  SellerOrderData.fromJson(Map<String, dynamic> json) {
    statusOrderCount = List.from(json['status_order_count'])
        .map(
          (e) => StatusOrderCount.fromJson(e),
        )
        .toList();
    orders = List.from(json['orders'])
        .map(
          (e) => SellerOrdersListItem.fromJson(e),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status_order_count'] = statusOrderCount
        ?.map(
          (e) => e.toJson(),
        )
        .toList();
    _data['orders'] = orders
        ?.map(
          (e) => e.toJson(),
        )
        .toList();
    return _data;
  }
}

class SellerOrdersListItem {
  SellerOrdersListItem({
    this.id,
    this.deliveryBoyId,
    this.orderId,
    this.mobile,
    this.orderNote,
    this.total,
    this.deliveryCharge,
    this.taxAmount,
    this.taxPercentage,
    this.discount,
    this.finalTotal,
    this.paymentMethod,
    this.address,
    this.latitude,
    this.longitude,
    this.deliveryTime,
    this.activeStatus,
    this.addressId,
    this.createdAt,
    this.deliveryBoyName,
    this.userName,
    this.orderStatus,
  });

  late final String? id;
  late final String? deliveryBoyId;
  late final String? orderId;
  late final String? mobile;
  late final String? orderNote;
  late final String? total;
  late final String? deliveryCharge;
  late final String? taxAmount;
  late final String? taxPercentage;
  late final String? discount;
  late final String? finalTotal;
  late final String? paymentMethod;
  late final String? address;
  late final String? latitude;
  late final String? longitude;
  late final String? deliveryTime;
  late final String? activeStatus;
  late final String? addressId;
  late final String? createdAt;
  late final String? deliveryBoyName;
  late final String? userName;
  late final String? orderStatus;

  SellerOrdersListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    deliveryBoyId = json['delivery_boy_id'].toString();
    orderId = json['order_id'].toString();
    mobile = json['mobile'].toString();
    orderNote = json['order_note'].toString();
    total = json['total'].toString();
    deliveryCharge = json['delivery_charge'].toString();
    taxAmount = json['tax_amount'].toString();
    taxPercentage = json['tax_percentage'].toString();
    discount = json['discount'].toString();
    finalTotal = json['final_total'].toString();
    paymentMethod = json['payment_method'].toString();
    address = json['address'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    deliveryTime = json['delivery_time'].toString();
    activeStatus = json['active_status'].toString();
    addressId = json['address_id'].toString();
    createdAt = json['created_at'].toString();
    deliveryBoyName = json['delivery_boy_name'].toString();
    userName = json['user_name'].toString();
    orderStatus = json['order_status'].toString();
  }

  SellerOrdersListItem copyWith(
      {String? newDeliveryBoyId,
      String? newDeliveryBoyName,
      String? activeStatus}) {
    return SellerOrdersListItem(
      id: this.id,
      deliveryBoyId: newDeliveryBoyId ?? this.deliveryBoyId,
      orderId: this.orderId,
      mobile: this.mobile,
      orderNote: this.orderNote,
      total: this.total,
      deliveryCharge: this.deliveryCharge,
      taxAmount: this.taxAmount,
      taxPercentage: this.taxPercentage,
      discount: this.discount,
      finalTotal: this.finalTotal,
      paymentMethod: this.paymentMethod,
      address: this.address,
      latitude: this.latitude,
      longitude: this.longitude,
      deliveryTime: this.deliveryTime,
      activeStatus: activeStatus ?? this.activeStatus,
      addressId: this.addressId,
      createdAt: this.createdAt,
      deliveryBoyName: newDeliveryBoyName ?? this.deliveryBoyName,
      userName: this.userName,
      orderStatus: this.orderStatus,
    );
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['delivery_boy_id'] = deliveryBoyId;
    _data['order_id'] = orderId;
    _data['mobile'] = mobile;
    _data['order_note'] = orderNote;
    _data['total'] = total;
    _data['delivery_charge'] = deliveryCharge;
    _data['tax_amount'] = taxAmount;
    _data['tax_percentage'] = taxPercentage;
    _data['discount'] = discount;
    _data['final_total'] = finalTotal;
    _data['payment_method'] = paymentMethod;
    _data['address'] = address;
    _data['latitude'] = latitude;
    _data['longitude'] = longitude;
    _data['delivery_time'] = deliveryTime;
    _data['active_status'] = activeStatus;
    _data['address_id'] = addressId;
    _data['created_at'] = createdAt;
    _data['delivery_boy_name'] = deliveryBoyName;
    _data['user_name'] = userName;
    _data['order_status'] = orderStatus;
    return _data;
  }
}
