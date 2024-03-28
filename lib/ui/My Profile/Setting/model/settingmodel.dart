class SettingModel {
  int? status;
  String? message;
  int? isNotification;

  SettingModel({this.status, this.message, this.isNotification});

  SettingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    isNotification = json['is_notification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['is_notification'] = isNotification;
    return data;
  }
}
