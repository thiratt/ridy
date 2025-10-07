// lib/models/user_signup_draft.dart
import 'package:image_picker/image_picker.dart';

class AddressInfo {
  final String label; // ชื่อเล่นที่อยู่ (เช่น บ้าน)
  final String text; // ที่อยู่อ่านได้
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
  final XFile avatar; // รูปโปรไฟล์
  final String role = 'rider';
  final String vehiclePlateNumber; // เลขทะเบียนรถ
  XFile? vehicleImage; // รูปภาพรถ

  RiderSignupDraft({
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.password,
    required this.avatar,
    required this.vehiclePlateNumber,
  });
}
