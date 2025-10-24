// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String status;
  String message;
  Data data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String id;
  String role;
  String phoneNumber;
  String firstname;
  String lastname;
  String avatarUrl;

  Data({
    required this.id,
    required this.role,
    required this.phoneNumber,
    required this.firstname,
    required this.lastname,
    required this.avatarUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    role: json["role"],
    phoneNumber: json["phoneNumber"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    avatarUrl: json["avatarUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "phoneNumber": phoneNumber,
    "firstname": firstname,
    "lastname": lastname,
    "avatarUrl": avatarUrl,
  };

  String get fullName {
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      return '$firstname $lastname';
    }
    return firstname;
  }
}
