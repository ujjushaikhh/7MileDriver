class LoginModel {
  int? status;
  String? message;
  Data? data;

  LoginModel({this.status, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  String? apiToken;
  int? id;
  String? name;
  String? email;
  String? countryCode;
  String? phone;
  String? dateOfBirth;
  bool? isNotification;
  int? isAdded;
  String? deviceId;
  String? deviceType;
  String? profileImage;

  Data(
      {this.apiToken,
      this.id,
      this.name,
      this.email,
      this.countryCode,
      this.phone,
      this.dateOfBirth,
      this.isAdded,
      this.deviceId,
      this.deviceType,
      this.isNotification,
      this.profileImage});

  Data.fromJson(Map<String, dynamic> json) {
    apiToken = json['api_token'];
    id = json['id'];
    name = json['name'];
    isNotification = json['is_notification'];
    email = json['email'];
    countryCode = json['country_code'];
    phone = json['phone'];
    dateOfBirth = json['date_of_birth'];
    isAdded = json['is_added'];
    deviceId = json['device_id'];
    deviceType = json['device_type'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api_token'] = apiToken;
    data['id'] = id;
    data['name'] = name;
    data['is_notification'] = isNotification;
    data['email'] = email;
    data['country_code'] = countryCode;
    data['phone'] = phone;
    data['date_of_birth'] = dateOfBirth;
    data['is_added'] = isAdded;
    data['device_id'] = deviceId;
    data['device_type'] = deviceType;
    data['profile_image'] = profileImage;
    return data;
  }
}
