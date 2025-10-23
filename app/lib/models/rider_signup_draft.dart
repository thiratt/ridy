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

class RiderSignupDraft {
  final String firstname;
  final String? lastname;
  final String phone;
  final String password;
  final XFile avatar;
  final String role = 'rider';
  final String vehiclePlateNumber;
  XFile? vehicleImage;

  RiderSignupDraft({
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.password,
    required this.avatar,
    required this.vehiclePlateNumber,
  });
}
