// To parse this JSON data, do
//
//     final userInformation = userInformationFromJson(jsonString);

import 'dart:convert';

UserInformation userInformationFromJson(String str) =>
    UserInformation.fromJson(json.decode(str));

String userInformationToJson(UserInformation data) =>
    json.encode(data.toJson());

class UserInformation {
  String id;
  String firstname;
  String? lastname;
  String fullname;
  String phoneNumber;
  String role;
  String avatarUrl;
  String createdAt;
  List<Address> addresses;
  List<Address> pickupAddresses;

  UserInformation({
    required this.id,
    required this.firstname,
    this.lastname,
    required this.fullname,
    required this.phoneNumber,
    required this.role,
    required this.avatarUrl,
    required this.createdAt,
    required this.addresses,
    required this.pickupAddresses,
  });

  factory UserInformation.fromJson(Map<String, dynamic> json) =>
      UserInformation(
        id: json["id"],
        firstname: json["firstname"],
        lastname: json["lastname"],
        fullname: json["fullname"],
        phoneNumber: json["phoneNumber"],
        role: json["role"],
        avatarUrl: json["avatarUrl"],
        createdAt: json["createdAt"],
        addresses: List<Address>.from(
          json["addresses"].map((x) => Address.fromJson(x)),
        ),
        pickupAddresses: List<Address>.from(
          json["pickupAddresses"].map((x) => Address.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "fullname": fullname,
    "phoneNumber": phoneNumber,
    "role": role,
    "avatarUrl": avatarUrl,
    "createdAt": createdAt,
    "addresses": List<dynamic>.from(addresses.map((x) => x.toJson())),
    "pickupAddresses": List<dynamic>.from(
      pickupAddresses.map((x) => x.toJson()),
    ),
  };
}

class Address {
  int id;
  String addressText;
  String label;
  double latitude;
  double longitude;
  DateTime createdAt;

  Address({
    required this.id,
    required this.addressText,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
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
