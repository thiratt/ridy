import 'dart:convert';

import 'package:app/models/user_information.dart';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String status;
  String message;
  UserInformation data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    message: json["message"],
    data: UserInformation.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String id;
  String firstname;
  String lastname;
  String phoneNumber;
  String role;
  String avatarUrl;
  String createdAt;
  String updatedAt;
  List<UserAddress> userAddresses;
  List<UserAddress> userPickupAddresses;

  Data({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    required this.role,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.userAddresses,
    required this.userPickupAddresses,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    phoneNumber: json["phoneNumber"],
    role: json["role"],
    avatarUrl: json["avatarUrl"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    userAddresses: List<UserAddress>.from(
      json["userAddresses"].map((x) => UserAddress.fromJson(x)),
    ),
    userPickupAddresses: List<UserAddress>.from(
      json["userPickupAddresses"].map((x) => UserAddress.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "phoneNumber": phoneNumber,
    "role": role,
    "avatarUrl": avatarUrl,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "userAddresses": List<dynamic>.from(userAddresses.map((x) => x.toJson())),
    "userPickupAddresses": List<dynamic>.from(
      userPickupAddresses.map((x) => x.toJson()),
    ),
  };
}

class UserAddress {
  int id;
  String addressText;
  String label;
  double latitude;
  double longitude;
  DateTime createdAt;

  UserAddress({
    required this.id,
    required this.addressText,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    id: json["id"],
    addressText: json["addressText"],
    label: json["label"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "addressText": addressText,
    "label": label,
    "latitude": latitude,
    "longitude": longitude,
    "createdAt": createdAt.toIso8601String(),
  };
}
