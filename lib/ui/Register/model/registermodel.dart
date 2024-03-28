class RegisterModel {
  int? status;
  String? message;
  Data? data;
  String? stripeAccountLink;

  RegisterModel({this.status, this.message, this.data, this.stripeAccountLink});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    stripeAccountLink = json['stripe_account_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['stripe_account_link'] = stripeAccountLink;
    return data;
  }
}

class Data {
  String? email;
  String? password;
  String? deviceType;
  String? name;
  String? phone;
  String? dateOfBirth;
  String? deviceId;
  String? countryCode;
  String? apiToken;
  String? profileImage;
  int? isAdded;
  bool? isNotification;

  Data(
      {this.email,
      this.password,
      this.deviceType,
      this.name,
      this.phone,
      this.dateOfBirth,
      this.deviceId,
      this.countryCode,
      this.apiToken,
      this.profileImage,
      this.isAdded,
      this.isNotification});

  Data.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    deviceType = json['device_type'];
    name = json['name'];
    phone = json['phone'];
    dateOfBirth = json['date_of_birth'];
    deviceId = json['device_id'];
    countryCode = json['country_code'];
    apiToken = json['api_token'];
    profileImage = json['profile_image'];
    isAdded = json['is_added'];
    isNotification = json['is_notification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['device_type'] = deviceType;
    data['name'] = name;
    data['phone'] = phone;
    data['date_of_birth'] = dateOfBirth;
    data['device_id'] = deviceId;
    data['country_code'] = countryCode;
    data['api_token'] = apiToken;
    data['profile_image'] = profileImage;
    data['is_added'] = isAdded;
    data['is_notification'] = isNotification;
    return data;
  }
}
