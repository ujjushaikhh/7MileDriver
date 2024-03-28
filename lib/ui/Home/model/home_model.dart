class GetHomeModel {
  int? status;
  String? message;
  List<Data>? data;

  GetHomeModel({this.status, this.message, this.data});

  GetHomeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? cartId;
  String? orderId;
  int? userId;
  String? userName;
  String? userImage;
  String? houseNo;
  String? landmark;
  String? address;
  String? city;
  String? state;
  String? zipcode;
  int? isCompleted;
  int? isAccepted;
  int? itemCount;

  Data(
      {this.cartId,
      this.orderId,
      this.userId,
      this.userName,
      this.userImage,
      this.houseNo,
      this.landmark,
      this.address,
      this.city,
      this.state,
      this.zipcode,
      this.isCompleted,
      this.isAccepted,
      this.itemCount});

  Data.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    orderId = json['order_id'];
    userId = json['user_id'];
    userName = json['user_name'];
    userImage = json['user_image'];
    houseNo = json['house_no'];
    landmark = json['landmark'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    isCompleted = json['is_completed'];
    isAccepted = json['is_accepted'];
    itemCount = json['item_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['order_id'] = orderId;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['user_image'] = userImage;
    data['house_no'] = houseNo;
    data['landmark'] = landmark;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['is_completed'] = isCompleted;
    data['is_accepted'] = isAccepted;
    data['item_count'] = itemCount;
    return data;
  }
}
