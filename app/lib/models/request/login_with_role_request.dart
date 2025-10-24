// To parse this JSON data, do
//
//     final loginWithRoleRequest = loginWithRoleRequestToJson(data);

import 'dart:convert';

String loginWithRoleRequestToJson(LoginWithRoleRequest data) =>
    json.encode(data.toJson());

class LoginWithRoleRequest {
  String phoneNumber;
  String password;
  String role;

  LoginWithRoleRequest({
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    "phoneNumber": phoneNumber,
    "password": password,
    "role": role,
  };
}
