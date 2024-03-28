class UploadVehicleModel {
  int? status;
  String? message;
  Data? data;

  UploadVehicleModel({this.status, this.message, this.data});

  UploadVehicleModel.fromJson(Map<String, dynamic> json) {
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
  int? vehicleId;
  String? modelId;
  String? makeId;
  String? typeId;
  int? driverId;
  String? modelYear;
  String? vehicleNumber;
  List<Images>? images;

  Data(
      {this.vehicleId,
      this.modelId,
      this.makeId,
      this.typeId,
      this.driverId,
      this.modelYear,
      this.vehicleNumber,
      this.images});

  Data.fromJson(Map<String, dynamic> json) {
    vehicleId = json['vehicle_id'];
    modelId = json['model_id'];
    makeId = json['make_id'];
    typeId = json['type_id'];
    driverId = json['driver_id'];
    modelYear = json['model_year'];
    vehicleNumber = json['vehicle_number'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicle_id'] = vehicleId;
    data['model_id'] = modelId;
    data['make_id'] = makeId;
    data['type_id'] = typeId;
    data['driver_id'] = driverId;
    data['model_year'] = modelYear;
    data['vehicle_number'] = vehicleNumber;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  int? imageId;
  int? vehicleId;
  String? image;

  Images({this.imageId, this.vehicleId, this.image});

  Images.fromJson(Map<String, dynamic> json) {
    imageId = json['image_id'];
    vehicleId = json['vehicle_id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_id'] = imageId;
    data['vehicle_id'] = vehicleId;
    data['image'] = image;
    return data;
  }
}
