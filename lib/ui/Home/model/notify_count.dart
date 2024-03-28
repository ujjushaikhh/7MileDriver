class NotifyCountModel {
  int? status;
  String? message;
  int? count;

  NotifyCountModel({this.status, this.message, this.count});

  NotifyCountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['count'] = count;
    return data;
  }
}
