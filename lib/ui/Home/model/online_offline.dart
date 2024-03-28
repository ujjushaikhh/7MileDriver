class OnlineOfflineModel {
  int? status;
  int? isOnline;
  String? message;

  OnlineOfflineModel({this.status, this.isOnline, this.message});

  OnlineOfflineModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    isOnline = json['is_online'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['is_online'] = isOnline;
    data['message'] = message;
    return data;
  }
}
