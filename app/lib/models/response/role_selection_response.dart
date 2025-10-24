// To parse this JSON data, do
//
//     final roleSelectionResponse = roleSelectionResponseFromJson(jsonString);

import 'dart:convert';

RoleSelectionResponse roleSelectionResponseFromJson(String str) =>
    RoleSelectionResponse.fromJson(json.decode(str));

String roleSelectionResponseToJson(RoleSelectionResponse data) =>
    json.encode(data.toJson());

class RoleSelectionResponse {
  String status;
  String message;
  RoleSelectionData data;

  RoleSelectionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RoleSelectionResponse.fromJson(Map<String, dynamic> json) =>
      RoleSelectionResponse(
        status: json["status"],
        message: json["message"],
        data: RoleSelectionData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class RoleSelectionData {
  bool requireRoleSelection;
  List<AvailableRole> availableRoles;

  RoleSelectionData({
    required this.requireRoleSelection,
    required this.availableRoles,
  });

  factory RoleSelectionData.fromJson(Map<String, dynamic> json) =>
      RoleSelectionData(
        requireRoleSelection: json["requireRoleSelection"],
        availableRoles: List<AvailableRole>.from(
          json["availableRoles"].map((x) => AvailableRole.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "requireRoleSelection": requireRoleSelection,
    "availableRoles": List<dynamic>.from(availableRoles.map((x) => x.toJson())),
  };
}

class AvailableRole {
  String id;
  String role;
  String roleDisplayName;
  String phoneNumber;
  String firstname;
  String? lastname;

  AvailableRole({
    required this.id,
    required this.role,
    required this.roleDisplayName,
    required this.phoneNumber,
    required this.firstname,
    this.lastname,
  });

  factory AvailableRole.fromJson(Map<String, dynamic> json) => AvailableRole(
    id: json["id"],
    role: json["role"],
    roleDisplayName: json["roleDisplayName"],
    phoneNumber: json["phoneNumber"],
    firstname: json["firstname"],
    lastname: json["lastname"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "roleDisplayName": roleDisplayName,
    "phoneNumber": phoneNumber,
    "firstname": firstname,
    "lastname": lastname,
  };

  String get fullName {
    if (lastname != null && lastname!.isNotEmpty) {
      return '$firstname $lastname';
    }
    return firstname;
  }
}
