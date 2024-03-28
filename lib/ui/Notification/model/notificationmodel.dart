class NotificationModel {
  int? status;
  String? message;
  List<Data>? data;

  NotificationModel({this.status, this.message, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
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
  String? notiTitle;
  String? notiMsg;
  int? notiRead;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.notiTitle,
      this.notiMsg,
      this.notiRead,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notiTitle = json['noti_title'];
    notiMsg = json['noti_msg'];
    notiRead = json['noti_read'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['noti_title'] = notiTitle;
    data['noti_msg'] = notiMsg;
    data['noti_read'] = notiRead;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
