import 'dart:convert';

SignupResponse signupResponseFromJson(String str) =>
    SignupResponse.fromJson(json.decode(str));

String signupResponseToJson(SignupResponse data) => json.encode(data.toJson());

class SignupResponse {
  String status;
  String message;
  SignupData data;

  SignupResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
    status: json["status"],
    message: json["message"],
    data: SignupData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class SignupData {
  String id;
  String role;
  String? phoneNumber;
  String? firstname;
  String? lastname;

  SignupData({
    required this.id,
    required this.role,
    this.phoneNumber,
    this.firstname,
    this.lastname,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) => SignupData(
    id: json["id"],
    role: json["role"],
    phoneNumber: json["phoneNumber"],
    firstname: json["firstname"],
    lastname: json["lastname"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "phoneNumber": phoneNumber,
    "firstname": firstname,
    "lastname": lastname,
  };

  String get fullName {
    if (firstname != null && lastname != null && lastname!.isNotEmpty) {
      return '$firstname $lastname';
    }
    return firstname ?? '';
  }
}
