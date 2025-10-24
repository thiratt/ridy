class Delivery {
  final String id;
  final String senderId;
  final String receiverId;
  final int pickupAddressId;
  final int dropoffAddressId;
  final String? riderId;
  final String baseStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserAddress? pickupAddress;
  final UserAddress? dropoffAddress;
  final Account? sender;
  final Account? receiver;
  final Account? rider;

  const Delivery({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.pickupAddressId,
    required this.dropoffAddressId,
    this.riderId,
    required this.baseStatus,
    required this.createdAt,
    required this.updatedAt,
    this.pickupAddress,
    this.dropoffAddress,
    this.sender,
    this.receiver,
    this.rider,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      pickupAddressId: json['pickupAddressId'] ?? 0,
      dropoffAddressId: json['dropoffAddressId'] ?? 0,
      riderId: json['riderId'],
      baseStatus: json['baseStatus'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      pickupAddress: json['pickupAddress'] != null
          ? UserAddress.fromJson(json['pickupAddress'])
          : null,
      dropoffAddress: json['dropoffAddress'] != null
          ? UserAddress.fromJson(json['dropoffAddress'])
          : null,
      sender: json['sender'] != null ? Account.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null
          ? Account.fromJson(json['receiver'])
          : null,
      rider: json['rider'] != null ? Account.fromJson(json['rider']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'pickupAddressId': pickupAddressId,
      'dropoffAddressId': dropoffAddressId,
      'riderId': riderId,
      'baseStatus': baseStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pickupAddress': pickupAddress?.toJson(),
      'dropoffAddress': dropoffAddress?.toJson(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
      'rider': rider?.toJson(),
    };
  }

  String get statusText {
    switch (baseStatus.toLowerCase()) {
      case 'pending':
        return 'รอการยืนยัน';
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'picked_up':
        return 'รับสินค้าแล้ว';
      case 'in_transit':
        return 'กำลังส่ง';
      case 'delivered':
        return 'ส่งสำเร็จ';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return baseStatus;
    }
  }

  String get deliveryDescription {
    final pickup = pickupAddress?.addressText ?? 'ที่อยู่รับสินค้า';
    final dropoff = dropoffAddress?.addressText ?? 'ที่อยู่ส่งสินค้า';
    return 'จาก: $pickup\nไปยัง: $dropoff';
  }
}

class UserAddress {
  final int id;
  final String userId;
  final String label;
  final String addressText;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  const UserAddress({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      label: json['label'] ?? '',
      addressText: json['addressText'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'addressText': addressText,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Account {
  final String id;
  final String phoneNumber;
  final String firstname;
  final String? lastname;
  final String? avatarUrl;
  final String role;

  const Account({
    required this.id,
    required this.phoneNumber,
    required this.firstname,
    this.lastname,
    this.avatarUrl,
    required this.role,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'firstname': firstname,
      'lastname': lastname,
      'avatarUrl': avatarUrl,
      'role': role,
    };
  }

  String get fullName {
    if (lastname != null && lastname!.isNotEmpty) {
      return '$firstname $lastname';
    }
    return firstname;
  }
}
