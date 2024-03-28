class GetVehicleModel {
  int? status;
  String? message;
  Data? data;

  GetVehicleModel({this.status, this.message, this.data});

  GetVehicleModel.fromJson(Map<String, dynamic> json) {
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
  List<VehicleModel>? vehicleModel;
  List<VehicleType>? vehicleType;
  List<VehicleMake>? vehicleMake;
  List<VehicleYear>? vehicleYear;

  Data(
      {this.vehicleModel,
      this.vehicleType,
      this.vehicleMake,
      this.vehicleYear});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['vehicle_model'] != null) {
      vehicleModel = <VehicleModel>[];
      json['vehicle_model'].forEach((v) {
        vehicleModel!.add(VehicleModel.fromJson(v));
      });
    }
    if (json['vehicle_type'] != null) {
      vehicleType = <VehicleType>[];
      json['vehicle_type'].forEach((v) {
        vehicleType!.add(VehicleType.fromJson(v));
      });
    }
    if (json['vehicle_make'] != null) {
      vehicleMake = <VehicleMake>[];
      json['vehicle_make'].forEach((v) {
        vehicleMake!.add(VehicleMake.fromJson(v));
      });
    }
    if (json['vehicle_year'] != null) {
      vehicleYear = <VehicleYear>[];
      json['vehicle_year'].forEach((v) {
        vehicleYear!.add(VehicleYear.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vehicleModel != null) {
      data['vehicle_model'] = vehicleModel!.map((v) => v.toJson()).toList();
    }
    if (vehicleType != null) {
      data['vehicle_type'] = vehicleType!.map((v) => v.toJson()).toList();
    }
    if (vehicleMake != null) {
      data['vehicle_make'] = vehicleMake!.map((v) => v.toJson()).toList();
    }
    if (vehicleYear != null) {
      data['vehicle_year'] = vehicleYear!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleModel {
  int? modelId;
  String? modelName;

  VehicleModel({this.modelId, this.modelName});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    modelId = json['model_id'];
    modelName = json['model_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['model_id'] = modelId;
    data['model_name'] = modelName;
    return data;
  }
}

class VehicleType {
  int? typeId;
  String? type;

  VehicleType({this.typeId, this.type});

  VehicleType.fromJson(Map<String, dynamic> json) {
    typeId = json['type_id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type_id'] = typeId;
    data['type'] = type;
    return data;
  }
}

class VehicleMake {
  int? makeId;
  String? make;

  VehicleMake({this.makeId, this.make});

  VehicleMake.fromJson(Map<String, dynamic> json) {
    makeId = json['make_id'];
    make = json['make'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['make_id'] = makeId;
    data['make'] = make;
    return data;
  }
}

class VehicleYear {
  int? yearId;
  int? yearName;

  VehicleYear({this.yearId, this.yearName});

  VehicleYear.fromJson(Map<String, dynamic> json) {
    yearId = json['year_id'];
    yearName = json['year_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['year_id'] = yearId;
    data['year_name'] = yearName;
    return data;
  }
}
