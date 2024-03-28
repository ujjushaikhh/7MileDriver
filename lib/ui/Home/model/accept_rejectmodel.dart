class AcceptRejectModel {
  int? status;
  String? message;
  int? id;
  int? cartId;
  String? s7mileNumber;
  int? userId;
  String? userName;
  String? userMobile;
  int? driverId;
  int? isAccepted;
  String? orderId;
  int? addressId;
  String? houseNo;
  String? landmark;
  String? address;
  String? city;
  String? state;
  String? zipcode;
  List<Products>? products;

  AcceptRejectModel(
      {this.status,
      this.message,
      this.id,
      this.cartId,
      this.s7mileNumber,
      this.userId,
      this.userName,
      this.userMobile,
      this.driverId,
      this.isAccepted,
      this.orderId,
      this.addressId,
      this.houseNo,
      this.landmark,
      this.address,
      this.city,
      this.state,
      this.zipcode,
      this.products});

  AcceptRejectModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    id = json['id'];
    cartId = json['cart_id'];
    s7mileNumber = json['7mile_number'];
    userId = json['user_id'];
    userName = json['user_name'];
    userMobile = json['user_mobile'];
    driverId = json['driver_id'];
    isAccepted = json['is_accepted'];
    orderId = json['order_id'];
    addressId = json['address_id'];
    houseNo = json['house_no'];
    landmark = json['landmark'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['id'] = id;
    data['cart_id'] = cartId;
    data['7mile_number'] = s7mileNumber;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['user_mobile'] = userMobile;
    data['driver_id'] = driverId;
    data['is_accepted'] = isAccepted;
    data['order_id'] = orderId;
    data['address_id'] = addressId;
    data['house_no'] = houseNo;
    data['landmark'] = landmark;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? cartDetailsId;
  String? productName;
  String? productPrice;
  String? productImage;
  int? collected;

  Products(
      {this.cartDetailsId,
      this.productName,
      this.productPrice,
      this.productImage,
      this.collected});

  Products.fromJson(Map<String, dynamic> json) {
    cartDetailsId = json['cart_details_id'];
    productName = json['product_name'];
    productPrice = json['product_price'];
    productImage = json['product_image'];
    collected = json['collected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_details_id'] = cartDetailsId;
    data['product_name'] = productName;
    data['product_price'] = productPrice;
    data['product_image'] = productImage;
    data['collected'] = collected;
    return data;
  }
}
