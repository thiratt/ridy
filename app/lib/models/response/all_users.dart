import 'dart:convert';
import 'package:app/models/user_information.dart';

AllUsers allUsersFromJson(String str) => AllUsers.fromJson(json.decode(str));

String allUsersToJson(AllUsers data) => json.encode(data.toJson());

class AllUsers {
    String status;
    String message;
    List<UserInformation> data;

    AllUsers({
        required this.status,
        required this.message,
        required this.data,
    });

    factory AllUsers.fromJson(Map<String, dynamic> json) => AllUsers(
        status: json["status"],
        message: json["message"],
        data: List<UserInformation>.from(json["data"].map((x) => UserInformation.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}