class UploadDocModel {
  int? status;
  String? message;
  Responses? responses;

  UploadDocModel({this.status, this.message, this.responses});

  UploadDocModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    responses = json['responses'] != null
        ? Responses.fromJson(json['responses'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (responses != null) {
      data['responses'] = responses!.toJson();
    }
    return data;
  }
}

class Responses {
  String? drivingLicence;
  String? vehicleRegistrationDocuments;
  String? vehicleInsuranceNumber;

  Responses(
      {this.drivingLicence,
      this.vehicleRegistrationDocuments,
      this.vehicleInsuranceNumber});

  Responses.fromJson(Map<String, dynamic> json) {
    drivingLicence = json['driving_licence'];
    vehicleRegistrationDocuments = json['vehicle_registration_documents'];
    vehicleInsuranceNumber = json['vehicle_insurance_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driving_licence'] = drivingLicence;
    data['vehicle_registration_documents'] = vehicleRegistrationDocuments;
    data['vehicle_insurance_number'] = vehicleInsuranceNumber;
    return data;
  }
}
