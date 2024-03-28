class MyDeliveriesModel {
  int? status;
  String? message;
  List<Data>? data;

  MyDeliveriesModel({this.status, this.message, this.data});

  MyDeliveriesModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? driverId;
  int? cartId;
  int? isCompleted;
  int? isCancel;
  String? rmdOrderId;
  int? userId;
  String? userName;
  String? userImage;
  String? houseNo;
  String? landmark;
  String? address;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? zipcode;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.driverId,
      this.cartId,
      this.isCompleted,
      this.rmdOrderId,
      this.userId,
      this.userName,
      this.userImage,
      this.houseNo,
      this.landmark,
      this.address,
      this.latitude,
      this.longitude,
      this.isCancel,
      this.city,
      this.state,
      this.zipcode,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driverId = json['driver_id'];
    cartId = json['cart_id'];
    isCompleted = json['is_completed'];
    rmdOrderId = json['rmd_order_id'];
    isCancel = json['is_cancel'];
    userId = json['user_id'];
    userName = json['user_name'];
    userImage = json['user_image'];
    houseNo = json['house_no'];
    landmark = json['landmark'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['driver_id'] = driverId;
    data['cart_id'] = cartId;
    data['is_completed'] = isCompleted;
    data['rmd_order_id'] = rmdOrderId;
    data['user_id'] = userId;
    data['is_cancel'] = isCancel;
    data['user_name'] = userName;
    data['user_image'] = userImage;
    data['house_no'] = houseNo;
    data['landmark'] = landmark;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
