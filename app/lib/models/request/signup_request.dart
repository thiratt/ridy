import 'package:image_picker/image_picker.dart';

class SignupRequest {
  final String phoneNumber;
  final String password;
  final String firstname;
  final String? lastname;
  final String role;
  final XFile avatarFileData;
  final List<String>? mainAddressTexts;
  final List<String>? mainAddressLabels;
  final List<double>? mainAddressLatitudes;
  final List<double>? mainAddressLongitudes;
  final List<String>? pickupAddressTexts;
  final List<String>? pickupAddressLabels;
  final List<double>? pickupAddressLatitudes;
  final List<double>? pickupAddressLongitudes;
  final String? addressText;
  final String? addressLabel;
  final double? addressLatitude;
  final double? addressLongitude;
  final String? pickupAddressText;
  final String? pickupAddressLabel;
  final double? pickupAddressLatitude;
  final double? pickupAddressLongitude;

  SignupRequest({
    required this.phoneNumber,
    required this.password,
    required this.firstname,
    this.lastname,
    required this.role,
    required this.avatarFileData,
    this.mainAddressTexts,
    this.mainAddressLabels,
    this.mainAddressLatitudes,
    this.mainAddressLongitudes,
    this.pickupAddressTexts,
    this.pickupAddressLabels,
    this.pickupAddressLatitudes,
    this.pickupAddressLongitudes,
    this.addressText,
    this.addressLabel,
    this.addressLatitude,
    this.addressLongitude,
    this.pickupAddressText,
    this.pickupAddressLabel,
    this.pickupAddressLatitude,
    this.pickupAddressLongitude,
  });
}
