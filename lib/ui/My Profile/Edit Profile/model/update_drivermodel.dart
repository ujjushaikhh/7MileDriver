class UpdateDriverModel {
  int? status;
  String? message;
  Driver? driver;

  UpdateDriverModel({this.status, this.message, this.driver});

  UpdateDriverModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }
}

class Driver {
  int? id;
  String? apiToken;
  String? profileImage;
  String? name;
  String? email;
  String? password;
  String? countryCode;
  String? phone;
  String? dateOfBirth;
  String? drivingLicence;
  String? vehicleRegistrationDocuments;
  String? vehicleInsuranceNumber;
  String? deviceId;
  String? deviceType;

  Driver(
      {this.id,
      this.apiToken,
      this.profileImage,
      this.name,
      this.email,
      this.password,
      this.countryCode,
      this.phone,
      this.dateOfBirth,
      this.drivingLicence,
      this.vehicleRegistrationDocuments,
      this.vehicleInsuranceNumber,
      this.deviceId,
      this.deviceType});

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    apiToken = json['api_token'];
    profileImage = json['profile_image'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    countryCode = json['country_code'];
    phone = json['phone'];
    dateOfBirth = json['date_of_birth'];
    drivingLicence = json['driving_licence'];
    vehicleRegistrationDocuments = json['vehicle_registration_documents'];
    vehicleInsuranceNumber = json['vehicle_insurance_number'];
    deviceId = json['device_id'];
    deviceType = json['device_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['api_token'] = apiToken;
    data['profile_image'] = profileImage;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['country_code'] = countryCode;
    data['phone'] = phone;
    data['date_of_birth'] = dateOfBirth;
    data['driving_licence'] = drivingLicence;
    data['vehicle_registration_documents'] = vehicleRegistrationDocuments;
    data['vehicle_insurance_number'] = vehicleInsuranceNumber;
    data['device_id'] = deviceId;
    data['device_type'] = deviceType;
    return data;
  }
}
