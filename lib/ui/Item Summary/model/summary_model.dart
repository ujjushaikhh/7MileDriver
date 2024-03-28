class ViewSummaryModel {
  int? status;
  String? message;
  Data? data;

  ViewSummaryModel({this.status, this.message, this.data});

  ViewSummaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? orderId;
  int? cartId;
  String? rmdId;
  int? isCompleted;
  String? createdAt;
  String? userName;
  String? userPhone;
  String? userImage;
  int? addressId;
  String? houseNo;
  String? landmark;
  String? city;
  String? state;
  String? zipcode;
  String? address;
  String? latitude;
  String? longitude;
  int? itemCount;
  String? totalAmount;
  int? isPickup;
  int? isCollect;
  int? isOfd;
  List<Items>? items;

  Data(
      {this.orderId,
      this.cartId,
      this.rmdId,
      this.isCompleted,
      this.createdAt,
      this.userName,
      this.userPhone,
      this.userImage,
      this.addressId,
      this.houseNo,
      this.landmark,
      this.city,
      this.state,
      this.zipcode,
      this.address,
      this.latitude,
      this.longitude,
      this.itemCount,
      this.totalAmount,
      this.isPickup,
      this.isCollect,
      this.isOfd,
      this.items});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    cartId = json['cart_id'];
    rmdId = json['rmd_id'];
    isCompleted = json['is_completed'];
    createdAt = json['created_at'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    userImage = json['user_image'];
    addressId = json['address_id'];
    houseNo = json['house_no'];
    landmark = json['landmark'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    itemCount = json['item_count'];
    totalAmount = json['total_amount'];
    isPickup = json['is_pickup'];
    isCollect = json['is_collect'];
    isOfd = json['is_ofd'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['cart_id'] = cartId;
    data['rmd_id'] = rmdId;
    data['is_completed'] = isCompleted;
    data['created_at'] = createdAt;
    data['user_name'] = userName;
    data['user_phone'] = userPhone;
    data['user_image'] = userImage;
    data['address_id'] = addressId;
    data['house_no'] = houseNo;
    data['landmark'] = landmark;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['item_count'] = itemCount;
    data['total_amount'] = totalAmount;
    data['is_pickup'] = isPickup;
    data['is_collect'] = isCollect;
    data['is_ofd'] = isOfd;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? cartDetailsId;
  int? productId;
  String? productName;
  String? productPrice;
  String? productImage;
  int? collected;

  Items(
      {this.cartDetailsId,
      this.productId,
      this.productName,
      this.productPrice,
      this.productImage,
      this.collected});

  Items.fromJson(Map<String, dynamic> json) {
    cartDetailsId = json['cart_details_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productPrice = json['product_price'];
    productImage = json['product_image'];
    collected = json['collected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_details_id'] = cartDetailsId;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_price'] = productPrice;
    data['product_image'] = productImage;
    data['collected'] = collected;
    return data;
  }
}
