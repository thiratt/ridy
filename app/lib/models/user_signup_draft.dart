import 'package:image_picker/image_picker.dart';

class AddressInfo {
  final String label;
  final String text;
  final double lat, lng;

  const AddressInfo({
    required this.label,
    required this.text,
    required this.lat,
    required this.lng,
  });
}

class UserSignupDraft {
  final String firstname;
  final String? lastname;
  final String phone;
  final String password;
  final XFile avatar;
  AddressInfo? main;
  AddressInfo? pickup;

  List<AddressInfo> mainAddresses = [];
  List<AddressInfo> pickupAddresses = [];

  final String role = 'user';

  UserSignupDraft({
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.password,
    required this.avatar,
    this.main,
    this.pickup,
    List<AddressInfo>? mainAddresses,
    List<AddressInfo>? pickupAddresses,
  }) {
    this.mainAddresses = mainAddresses ?? [];
    this.pickupAddresses = pickupAddresses ?? [];
  }
}
