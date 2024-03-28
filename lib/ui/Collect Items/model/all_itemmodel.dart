class AllItemsModel {
  int? status;
  String? message;
  Data? data;

  AllItemsModel({this.status, this.message, this.data});

  AllItemsModel.fromJson(Map<String, dynamic> json) {
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
  int? cartCompleted;
  String? createdAt;
  int? isPickup;
  int? isCollect;
  int? isOfd;
  int? isCompleted;
  List<AllItems>? items;

  Data(
      {this.orderId,
      this.cartId,
      this.rmdId,
      this.cartCompleted,
      this.createdAt,
      this.isPickup,
      this.isCollect,
      this.isOfd,
      this.isCompleted,
      this.items});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    cartId = json['cart_id'];
    rmdId = json['rmd_id'];
    cartCompleted = json['cart_completed'];
    createdAt = json['created_at'];
    isPickup = json['is_pickup'];
    isCollect = json['is_collect'];
    isOfd = json['is_ofd'];
    isCompleted = json['is_completed'];
    if (json['items'] != null) {
      items = <AllItems>[];
      json['items'].forEach((v) {
        items!.add(AllItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['cart_id'] = cartId;
    data['rmd_id'] = rmdId;
    data['cart_completed'] = cartCompleted;
    data['created_at'] = createdAt;
    data['is_pickup'] = isPickup;
    data['is_collect'] = isCollect;
    data['is_ofd'] = isOfd;
    data['is_completed'] = isCompleted;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllItems {
  int? cartDetailsId;
  int? productId;
  String? productName;
  String? productPrice;
  String? productImage;
  int? collected;

  AllItems(
      {this.cartDetailsId,
      this.productId,
      this.productName,
      this.productPrice,
      this.productImage,
      this.collected});

  AllItems.fromJson(Map<String, dynamic> json) {
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
