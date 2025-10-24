import 'dart:convert';

List<UserInformation> userInformationFromJson(String str) =>
    List<UserInformation>.from(
      json.decode(str).map((x) => UserInformation.fromJson(x)),
    );

String userInformationToJson(List<UserInformation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserInformation {
  String id;
  String firstname;
  String phoneNumber;
  String avatarUrl;
  String fullName;
  DateTime createdAt;
  List<Address> addresses;
  List<Address> pickupAddresses;
  String? lastname;

  UserInformation({
    required this.id,
    required this.firstname,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.fullName,
    required this.createdAt,
    required this.addresses,
    required this.pickupAddresses,
    this.lastname,
  });

  factory UserInformation.fromJson(Map<String, dynamic> json) =>
      UserInformation(
        id: json["id"],
        firstname: json["firstname"],
        phoneNumber: json["phoneNumber"],
        avatarUrl: json["avatarUrl"],
        fullName: json["fullName"],
        createdAt: DateTime.parse(json["createdAt"]),
        addresses: List<Address>.from(
          json["addresses"].map((x) => Address.fromJson(x)),
        ),
        pickupAddresses: List<Address>.from(
          json["pickupAddresses"].map((x) => Address.fromJson(x)),
        ),
        lastname: json["lastname"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "phoneNumber": phoneNumber,
    "avatarUrl": avatarUrl,
    "fullName": fullName,
    "createdAt": createdAt.toIso8601String(),
    "addresses": List<dynamic>.from(addresses.map((x) => x.toJson())),
    "pickupAddresses": List<dynamic>.from(
      pickupAddresses.map((x) => x.toJson()),
    ),
    "lastname": lastname,
  };
}

class Address {
  int id;
  String addressText;
  String? label;
  double latitude;
  double longitude;
  DateTime createdAt;

  Address({
    required this.id,
    required this.addressText,
    this.label,
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

class GetAllUsersResponse {
  final String status;
  final String message;
  final List<UserInformation> data;

  GetAllUsersResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllUsersResponse.fromJson(Map<String, dynamic> json) {
    return GetAllUsersResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((user) => UserInformation.fromJson(user))
          .toList(),
    );
  }
}
