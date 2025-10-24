import 'dart:convert';

import 'package:app/config/api_constants.dart';
import 'package:app/models/request/login_request.dart';
import 'package:app/models/request/login_with_role_request.dart';
import 'package:app/models/response/login_response.dart';
import 'package:app/models/response/role_selection_response.dart';
import 'package:app/shared/provider.dart';
import 'package:app/utils/request_helper.dart';
import 'package:http/http.dart' as http;

enum LoginResult {
  success,
  roleSelectionRequired,
  invalidCredentials,
  serverError,
  networkError,
}

class AuthLoginResponse {
  final LoginResult result;
  final String? message;
  final UserData? userData;
  final List<AvailableRole>? availableRoles;

  AuthLoginResponse({
    required this.result,
    this.message,
    this.userData,
    this.availableRoles,
  });
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

        final user = UserData(
          id: userData.id,
          role: userData.role,
          phoneNumber: userData.phoneNumber,
          firstname: userData.firstname,
          lastname: userData.lastname,
        );

        return AuthLoginResponse(result: LoginResult.success, userData: user);
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

  void saveUserToProvider(RidyProvider provider, UserData userData) {
    provider.setUser(userData);
  }
}
