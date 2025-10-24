import 'dart:convert';

import 'package:app/config/api_constants.dart';
import 'package:app/models/request/login_request.dart';
import 'package:app/models/request/login_with_role_request.dart';
import 'package:app/models/request/signup_request.dart';
import 'package:app/models/response/login_response.dart';
import 'package:app/models/response/role_selection_response.dart';
import 'package:app/models/response/signup_response.dart';
import 'package:app/models/user_information.dart';
import 'package:app/shared/provider.dart';
import 'package:app/utils/request_helper.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

enum LoginResult {
  success,
  roleSelectionRequired,
  invalidCredentials,
  serverError,
  networkError,
}

enum SignupResult {
  success,
  phoneNumberAlreadyExists,
  validationError,
  serverError,
  networkError,
}

class AuthLoginResponse {
  final LoginResult result;
  final String? message;
  final UserInformation? user;
  final List<AvailableRole>? availableRoles;

  AuthLoginResponse({
    required this.result,
    this.message,
    this.user,
    this.availableRoles,
  });
}

class AuthSignupResponse {
  final SignupResult result;
  final String? message;
  final UserInformation? user;

  AuthSignupResponse({required this.result, this.message, this.user});
}

class AuthenticationService {
  Future<AuthLoginResponse> login(String phoneNumber, String password) async {
    try {
      final loginRequest = LoginRequest(
        phoneNumber: phoneNumber.trim(),
        password: password,
      );

      final response = await http
          .post(
            Uri.parse(ApiConstants.buildUrlEndpoint(ApiRoute.login)),
            headers: buildHeaders(),
            body: loginRequestToJson(loginRequest),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
            },
          );

      return _handleLoginResponse(response);
    } catch (e) {
      return AuthLoginResponse(
        result: LoginResult.networkError,
        message: e.toString(),
      );
    }
  }

  Future<AuthLoginResponse> loginWithRole(
    String phoneNumber,
    String password,
    String role,
  ) async {
    try {
      final loginRequest = LoginWithRoleRequest(
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );

      final response = await http
          .post(
            Uri.parse(ApiConstants.buildUrlEndpoint(ApiRoute.loginWithRole)),
            headers: buildHeaders(),
            body: loginWithRoleRequestToJson(loginRequest),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
            },
          );

      return _handleLoginResponse(response);
    } catch (e) {
      return AuthLoginResponse(
        result: LoginResult.networkError,
        message: e.toString(),
      );
    }
  }

  AuthLoginResponse _handleLoginResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null &&
            responseData['data']['requireRoleSelection'] == true) {
          final roleSelectionResponse = roleSelectionResponseFromJson(
            response.body,
          );
          return AuthLoginResponse(
            result: LoginResult.roleSelectionRequired,
            availableRoles: roleSelectionResponse.data.availableRoles,
          );
        }

        final loginResponse = loginResponseFromJson(response.body);
        final userData = loginResponse.data;

        return AuthLoginResponse(result: LoginResult.success, user: userData);
      } catch (e) {
        return AuthLoginResponse(
          result: LoginResult.serverError,
          message: 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล',
        );
      }
    } else if (response.statusCode == 401) {
      return AuthLoginResponse(
        result: LoginResult.invalidCredentials,
        message: 'เบอร์โทรศัพท์หรือรหัสผ่านไม่ถูกต้อง',
      );
    } else if (response.statusCode >= 500) {
      return AuthLoginResponse(
        result: LoginResult.serverError,
        message: 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง',
      );
    } else {
      return AuthLoginResponse(
        result: LoginResult.serverError,
        message: 'เกิดข้อผิดพลาด: ${response.reasonPhrase ?? 'ไม่ทราบสาเหตุ'}',
      );
    }
  }

  Future<AuthSignupResponse> signup(SignupRequest signupRequest) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final Map<String, dynamic> formDataMap = {
        'PhoneNumber': signupRequest.phoneNumber,
        'Password': signupRequest.password,
        'Firstname': signupRequest.firstname,
        'Lastname': signupRequest.lastname ?? '',
        'Role': signupRequest.role,
        'AvatarFileData': await MultipartFile.fromFile(
          signupRequest.avatarFileData.path,
          filename: 'avatar.jpg',
        ),
      };

      if (signupRequest.mainAddressTexts != null &&
          signupRequest.mainAddressTexts!.isNotEmpty) {
        formDataMap['MainAddressTexts'] = signupRequest.mainAddressTexts;
        formDataMap['MainAddressLabels'] = signupRequest.mainAddressLabels;
        formDataMap['MainAddressLatitudes'] =
            signupRequest.mainAddressLatitudes;
        formDataMap['MainAddressLongitudes'] =
            signupRequest.mainAddressLongitudes;
      }

      if (signupRequest.pickupAddressTexts != null &&
          signupRequest.pickupAddressTexts!.isNotEmpty) {
        formDataMap['PickupAddressTexts'] = signupRequest.pickupAddressTexts;
        formDataMap['PickupAddressLabels'] = signupRequest.pickupAddressLabels;
        formDataMap['PickupAddressLatitudes'] =
            signupRequest.pickupAddressLatitudes;
        formDataMap['PickupAddressLongitudes'] =
            signupRequest.pickupAddressLongitudes;
      }

      if (signupRequest.addressText != null) {
        formDataMap['AddressText'] = signupRequest.addressText;
        formDataMap['AddressLabel'] = signupRequest.addressLabel;
        formDataMap['AddressLatitude'] = signupRequest.addressLatitude;
        formDataMap['AddressLongitude'] = signupRequest.addressLongitude;
      }

      if (signupRequest.pickupAddressText != null) {
        formDataMap['PickupAddressText'] = signupRequest.pickupAddressText;
        formDataMap['PickupAddressLabel'] = signupRequest.pickupAddressLabel;
        formDataMap['PickupAddressLatitude'] =
            signupRequest.pickupAddressLatitude;
        formDataMap['PickupAddressLongitude'] =
            signupRequest.pickupAddressLongitude;
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await dio.post(
        ApiConstants.buildUrlEndpoint(ApiRoute.register),
        data: formData,
      );

      return _handleSignupResponse(response);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return AuthSignupResponse(
            result: SignupResult.networkError,
            message: 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง',
          );
        } else if (e.response?.statusCode == 409) {
          return AuthSignupResponse(
            result: SignupResult.phoneNumberAlreadyExists,
            message: 'หมายเลขโทรศัพท์นี้ถูกใช้แล้ว กรุณาใช้หมายเลขอื่น',
          );
        }
      }

      return AuthSignupResponse(
        result: SignupResult.networkError,
        message: e.toString(),
      );
    }
  }

  AuthSignupResponse _handleSignupResponse(Response response) {
    if (response.statusCode == 200) {
      try {
        final signupResponse = signupResponseFromJson(
          json.encode(response.data),
        );
        final userData = signupResponse.data;

        return AuthSignupResponse(result: SignupResult.success, user: userData);
      } catch (e) {
        return AuthSignupResponse(
          result: SignupResult.serverError,
          message: 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล',
        );
      }
    } else if (response.statusCode == 409) {
      return AuthSignupResponse(
        result: SignupResult.phoneNumberAlreadyExists,
        message: 'หมายเลขโทรศัพท์นี้ถูกใช้แล้ว กรุณาใช้หมายเลขอื่น',
      );
    } else if (response.statusCode == 400) {
      return AuthSignupResponse(
        result: SignupResult.validationError,
        message: 'ข้อมูลที่กรอกไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง',
      );
    } else if (response.statusCode != null && response.statusCode! >= 500) {
      return AuthSignupResponse(
        result: SignupResult.serverError,
        message: 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง',
      );
    } else {
      return AuthSignupResponse(
        result: SignupResult.serverError,
        message: 'เกิดข้อผิดพลาด: ${response.statusMessage ?? 'ไม่ทราบสาเหตุ'}',
      );
    }
  }

  Future<bool> checkPhoneNumberAvailability(
    String phoneNumber,
    String role,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.buildUrlEndpoint(ApiRoute.checkPhoneNumber)),
            headers: buildHeaders(),
            body: json.encode({
              'phoneNumber': phoneNumber.trim(),
              'role': role,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
            },
          );

      if (response.statusCode == 200) {
        return true; // Phone number is available
      } else if (response.statusCode == 409) {
        return false; // Phone number already exists
      } else {
        throw 'เกิดข้อผิดพลาดในการตรวจสอบเบอร์โทรศัพท์';
      }
    } catch (e) {
      rethrow;
    }
  }

  void saveUserToProvider(RidyProvider provider, UserInformation userData) {
    provider.setUser(userData);
  }
}
